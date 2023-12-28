extends CharacterBody2D

@onready var sprite = $Sprite
@onready var coyote = $Coyote

@export var SPEED : float = 750.0
@export var JUMP_VELOCITY : float = -800.0
@export var AIR_JUMP_VELOCITY : float = -700.0
@export var DOWN_PULL : float = 1.5

var is_falling : bool = true
var can_jump : bool = false
var can_air_jump : bool = false

var dashing = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 2.0

func dash(direction):
	if direction:
		dashing = 6000 * direction
	velocity.x = dashing




func _physics_process(delta):
	if abs(dashing) > 5000:
		if abs(dashing) == 5100:
			velocity.x *= 0.1
	
	# gravity
	if not is_on_floor():
		if is_falling and coyote.is_stopped():
			if velocity.y < 0:
				velocity.y += gravity * delta
			else:
				velocity.y += gravity * delta * DOWN_PULL
		elif coyote.is_stopped():
			coyote.start()
	
	# reset double jump, can add in extra checks for charm in the future
	if is_on_floor():
		is_falling = false
		can_air_jump = false
		can_jump = true

	# Handles Jump, if player is on the ground or has double jump let them jump
	if Input.is_action_just_pressed("jump"):
		if not is_falling and can_jump:
			can_jump = false
			is_falling = true
			can_air_jump = true
			velocity.y = JUMP_VELOCITY
		elif is_falling and can_air_jump:
			can_air_jump = false
			velocity.y = AIR_JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 5)

	if Input.is_action_just_pressed("dash") and not dashing:
		dash(direction)
	
	dashing = move_toward(dashing, 0, 50)
	
	move_and_slide()

func _on_coyote_timeout():
	is_falling = true
	can_air_jump = true
