extends Area2D

@onready var collision_shape_2d = $CollisionShape2D

@onready var front_detect : RayCast2D = $FrontDetect
@onready var back_detect : RayCast2D = $BackDetect
@onready var floor_detect : RayCast2D = $Floor
@onready var aggression : Timer = $Aggression

@onready var sprite : AnimatedSprite2D = $Sprite2D
@onready var death = $Death

enum STATE {IDLE, AGGRESSIVE, DYING}
enum DIRECTION {LEFT, RIGHT}

@export var WALK_SPEED : float = 100.0
@export var RUN_SPEED : float = 200.0
@export var knockback : float = 500.0

var state : STATE = STATE.IDLE

## Easier way to set Start-Look direction per enemy
@export var direction : DIRECTION = DIRECTION.LEFT

var player : CharacterBody2D
var player_inside : bool = false
# lil hack to keep the values from accidentally becoming 0
var floor_detect_position : float
var look_distance : float

func _ready():
	floor_detect_position = floor_detect.position.x
	# backwards look is just half as long :/
	look_distance = front_detect.target_position.x

func walk(delta):
	var dir : float = 0.0
	match(direction):
		DIRECTION.LEFT:
			dir = -1.0
			sprite.flip_h = true
		DIRECTION.RIGHT:
			dir = 1.0
			sprite.flip_h = false
	floor_detect.force_raycast_update()
	if floor_detect.is_colliding() and floor_detect.get_collider().name != "Player":
		position.x += dir * WALK_SPEED * delta
		sprite.play("Walk")
	else:
		direction = DIRECTION.LEFT if direction == DIRECTION.RIGHT else DIRECTION.RIGHT
		floor_detect.position.x = dir * floor_detect_position
		front_detect.target_position.x = look_distance * -dir
		back_detect.target_position.x = look_distance * dir * 0.5
		
func run(delta):
	var dir : float = sign(player.position.x - position.x)
	floor_detect.position.x = -dir * floor_detect_position
	front_detect.target_position.x = look_distance * dir
	back_detect.target_position.x = look_distance * -dir * 0.5
	floor_detect.force_raycast_update()
	if dir < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	if floor_detect.is_colliding() and floor_detect.get_collider().name != "Player" and abs(player.position.x - position.x) > RUN_SPEED * delta:
		sprite.play("Run")
		position.x += dir * RUN_SPEED * delta
	elif sprite.is_playing():
		sprite.play("Stop")

func die():
	state = STATE.DYING

func _physics_process(delta):
	match(state):
		STATE.IDLE:
			walk(delta)
		STATE.AGGRESSIVE:
			run(delta)
		STATE.DYING:
			if death.playing:
				return
			death.play()
			sprite.play("Death")
			collision_shape_2d.disabled = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
	if front_detect.is_colliding():
		player = front_detect.get_collider()
		state = STATE.AGGRESSIVE
		aggression.start()
	elif back_detect.is_colliding():
		state = STATE.AGGRESSIVE
		aggression.start()
		player = back_detect.get_collider()
		
	# as it currently is implemented the player could get into the hitbox
	# and it wouldn't be detected, so just repeat the hit while inside
	if player_inside:
		player.hit(position.x, knockback)

func _on_aggression_timeout():
	state = STATE.IDLE


func _on_body_entered(body):
	player = body
	
	player_inside = true


func _on_body_exited(_body):
	player_inside = false
