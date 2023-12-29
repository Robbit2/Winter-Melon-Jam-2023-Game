extends Area2D

@onready var front_detect : RayCast2D = $FrontDetect
@onready var back_detect : RayCast2D = $BackDetect
@onready var floor_detect : RayCast2D = $Floor
@onready var aggression : Timer = $Aggression

enum STATE {IDLE, AGGRESSIVE}
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
		DIRECTION.RIGHT:
			dir = 1.0
	floor_detect.force_raycast_update()
	if floor_detect.is_colliding() and floor_detect.get_collider().name != "Player":
		position.x += dir * WALK_SPEED * delta
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
	if floor_detect.is_colliding() and floor_detect.get_collider().name != "Player" and abs(player.position.x - position.x) > RUN_SPEED * delta:
		position.x += dir * RUN_SPEED * delta

func _physics_process(delta):
	match(state):
		STATE.IDLE:
			walk(delta)
		STATE.AGGRESSIVE:
			run(delta)
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
