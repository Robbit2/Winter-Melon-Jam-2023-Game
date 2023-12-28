extends CharacterBody2D

@onready var sprite = $Sprite
@onready var coyote_timer : Timer = $Coyote
@onready var dash_timeout_timer : Timer = $DashTimeout
@onready var invincibility : Timer = $Invincibility

@export var SPEED : float = 750.0
@export var JUMP_VELOCITY : float = -800.0
@export var AIR_JUMP_VELOCITY : float = -700.0
## Gravity Strength Multiplier after Apex of Jump
@export_range (1.0, 2.5) var DOWN_PULL : float = 1.5
@export var DASH_SPEED_HORIZONTAL : float = 2000.0
@export var DASH_SPEED_VERTICAL : float = 1000.0
## How heavy the Movement feels (influences dash)
@export_range (0.1, 10.0) var WEIGHT_FACTOR : float = 3.0

var is_falling : bool = true
var can_jump : bool = false
var can_air_jump : bool = false
@export var action : String = "Idle"

var can_dash : bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func set_action(_action):
	action = str(_action)
	$Sprite.animation = action
	return true


func _physics_process(delta):
	
	# gravity
	if not is_on_floor():
		if is_falling and coyote_timer.is_stopped():
			if velocity.y < 0:
				velocity.y += gravity * delta
			else:
				velocity.y += gravity * delta * DOWN_PULL
		elif coyote_timer.is_stopped():
			coyote_timer.start()
	
	# reset jump and fall state, can add in extra checks for charm in the future
	if is_on_floor():
		is_falling = false
		can_air_jump = false
		can_jump = true

	# Handles Jump
	# if the player is not falling -> normal jump
	# if the player is falling -> air jump
	if Input.is_action_just_pressed("jump"):
		if not is_falling and can_jump:
			can_jump = false
			is_falling = true # a bit hacky, but we don't want coyote time to start on jump
			can_air_jump = true
			velocity.y = JUMP_VELOCITY
		elif is_falling and can_air_jump: # charm requirement can be placed here
			can_air_jump = false
			velocity.y = AIR_JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	# using move_toward for everything (not just deceleration) makes the movement more weighty
	# it also allows us to just add velocity to the dash and have it move smoothly into normal speed
	velocity.x = move_toward(velocity.x, direction * SPEED, SPEED / WEIGHT_FACTOR)


	if Input.is_action_just_pressed("dash") and can_dash:
		# up/down is inverted so DASH_SPEED_VERTICAL can have a positive sign
		var dash_direction = Input.get_vector("left", "right", "up", "down").normalized()
		dash_timeout_timer.start()
		invincibility.start()
		can_dash = false
		# resetting vertical speed is fine, resetting horizontal speed feels wrong
		velocity.x += sign(dash_direction.x) * DASH_SPEED_HORIZONTAL
		velocity.y = sign(dash_direction.y) * DASH_SPEED_VERTICAL
	
	move_and_slide()

func _on_coyote_timeout():
	is_falling = true
	can_air_jump = true

# can add some sound cue or something when dash is ready
func _on_dash_timeout():
	can_dash = true

func hit(enemy_pos_x : float, knockback : float):
	if invincibility.is_stopped():
		var dir : Vector2 = Vector2(sign(position.x - enemy_pos_x), -1.0).normalized()
		velocity = dir * Vector2(knockback * 5.0, knockback)
		invincibility.start()

func _on_invincibility_timeout():
	pass # Replace with function body.
