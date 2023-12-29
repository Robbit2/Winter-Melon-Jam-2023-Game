extends CharacterBody2D

@onready var player = $"."
@onready var sprite = $Sprite
@onready var coyote_timer : Timer = $Coyote
@onready var dash_timeout_timer : Timer = $DashTimeout
@onready var invincibility : Timer = $Invincibility
@onready var health_label = $"../UI/HealthPanel/HealthLabel"
@onready var death_screen = $"../UI/DeathScreen"
@onready var swordbox = $Sprite/SwordArea/Swordbox
var swordbox_dist

@export var SPEED : float = 750.0
@export var JUMP_VELOCITY : float = -800.0
@export var AIR_JUMP_VELOCITY : float = -700.0
## Gravity Strength Multiplier after Apex of Jump
@export_range (1.0, 2.5) var DOWN_PULL : float = 1.5
@export var DASH_SPEED_HORIZONTAL : float = 2000.0
@export var DASH_SPEED_VERTICAL : float = 1000.0
## How heavy the Movement feels (influences dash)
@export_range (0.1, 10.0) var WEIGHT_FACTOR : float = 3.0

## keep track of where we were looking
var look_dir : float = 1.0

var is_falling : bool = true
var can_jump : bool = false
var can_air_jump : bool = false
var is_attacking : bool = false
@export var action : String = "Idle"

var dead : bool = false
var can_dash : bool = true
var charms : int = 1
var health : int = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func attack():
	set_action("Attack")
	is_attacking = true
	swordbox.disabled = false

func set_action(_action):
	action = str(_action)
	sprite.play(action)
	return true

func _ready():
	swordbox_dist = abs(swordbox.position.x)

func _process(_delta):
	# flips the sprite if player is moving left and unflips if moving right
	if look_dir < 0.0:
		sprite.flip_h = false
	if look_dir > 0.0:
		sprite.flip_h = true
	swordbox.position.x = look_dir * swordbox_dist
	# hacky way to reset attack after animation ends
	if sprite.animation == "Attack" and not sprite.is_playing():
		is_attacking = false
		swordbox.disabled = true
		if is_falling:
			set_action("Fall")
		else:
			set_action("Idle")
	# hacky way to transition jump into looping fall animation
	if sprite.animation == "Jump" and not sprite.is_playing():
		set_action("Fall")

func _physics_process(delta):
	
	# gravity
	if not is_on_floor():
		if is_falling and coyote_timer.is_stopped():
			if velocity.y < 0.0:
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
	if Input.is_action_just_pressed("jump") and not dead and not is_attacking:
		if not is_falling and can_jump:
			set_action("Jump")
			sprite.frame = 0
			can_jump = false
			is_falling = true # a bit hacky, but we don't want coyote time to start on jump
			can_air_jump = true
			velocity.y = JUMP_VELOCITY
		elif is_falling and can_air_jump and charms >= 1: # charm requirement can be placed here
			set_action("Jump")
			sprite.frame = 0
			can_air_jump = false
			velocity.y = AIR_JUMP_VELOCITY
	
	if Input.is_action_just_pressed("attack") and not dead and not is_attacking:
		attack()
	
	var direction = Input.get_axis("left", "right") * (0.5 if is_attacking else 1.0)
	if abs(direction) > 0.001:
		look_dir = sign(direction)
	# changes player to running animation if they are moving
	if not is_falling and action != "Attack":
		if direction:
			set_action("Run")
		else:
			set_action("Idle")
	# using move_toward for everything (not just deceleration) makes the movement more weighty
	# it also allows us to just add velocity to the dash and have it move smoothly into normal speed
	if not dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED / WEIGHT_FACTOR)


	if Input.is_action_just_pressed("dash") and can_dash and charms >= 2 and not dead and not is_attacking:
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
	if not is_attacking:
		set_action("Fall")
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
		health -= 1
		GlobalSignals.emit_signal("UpdateHealth", health)
		check_dead()
		is_attacking = false
		set_deferred("swordbox.disabled", true)
		set_action("Fall")

func getCharm():
	charms += 1
	return true

func _on_invincibility_timeout():
	pass # Replace with function body.

func check_dead():
	if health <= 0:
		dead = true
		Engine.time_scale = 0
		death_screen.visible = true

# enemies are Area2Ds -> we need to check area entered
func _on_sword_area_area_entered(area):
	print(area.name)
	# just call all enemies Enemy... :)
	# I just deleted nodes with enemy in the name, this removed projectiles
	# was cool, now it's a feature
	if "EnemyProjectile" in area.name:
		area.queue_free()
	elif "Enemy" in area.name:
		area.die()
