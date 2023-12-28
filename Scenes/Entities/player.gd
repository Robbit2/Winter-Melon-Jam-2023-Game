extends CharacterBody2D

@onready var sprite = $Sprite

const SPEED = 750.0
const JUMP_VELOCITY = -400.0
var jumps = 2
var dashing = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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
		velocity.y += gravity * delta
	
	# reset double jump, can add in extra checks for charm in the future
	if is_on_floor():
		jumps = 2

	# Handles Jump, if player is on the ground or has double jump let them jump
	if Input.is_action_just_pressed("jump") and is_on_floor() or Input.is_action_just_pressed("jump") and jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps = max(0, jumps - 1)

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 5)

	if Input.is_action_just_pressed("dash") and not dashing:
		dash(direction)
	
	dashing = move_toward(dashing, 0, 50)
	
	move_and_slide()
