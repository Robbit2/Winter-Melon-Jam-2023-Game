extends Area2D

# I'm not commenting all that
@onready var color_rect = $ColorRect

@onready var path_BL : PathFollow2D = $"../PathBL/PathFollow"
@onready var path_BR : PathFollow2D = $"../PathBR/PathFollow"
@onready var path_LB : PathFollow2D = $"../PathLB/PathFollow"
@onready var path_LR : PathFollow2D = $"../PathLR/PathFollow"
@onready var path_RB : PathFollow2D = $"../PathRB/PathFollow"
@onready var path_RL : PathFollow2D = $"../PathRL/PathFollow"

@onready var danger : Timer = $Danger

var health := 15

enum STATE {BWAIT, BATTACK, BATTACK1, BATTACK2, 
			LWAIT, LATTACK1, LATTACK2,
			RWAIT, RATTACK1, RATTACK2,
			TRANSITION}
			
enum TRANSITIONS {BL, LB, BR, RB, LR, RL, BB, LL, RR}

var transitionDict := {
	STATE.BWAIT : [TRANSITIONS.BL, TRANSITIONS.BR, TRANSITIONS.BB],
	STATE.BATTACK : [TRANSITIONS.BL, TRANSITIONS.BR, TRANSITIONS.BB],
	STATE.BATTACK1 : [TRANSITIONS.BL, TRANSITIONS.BR, TRANSITIONS.BB],
	STATE.BATTACK2 : [TRANSITIONS.BL, TRANSITIONS.BR, TRANSITIONS.BB],
	STATE.LWAIT : [TRANSITIONS.LB, TRANSITIONS.LR, TRANSITIONS.LL],
	STATE.LATTACK1 : [TRANSITIONS.LB, TRANSITIONS.LR, TRANSITIONS.LL],
	STATE.LATTACK2 : [TRANSITIONS.LB, TRANSITIONS.LR, TRANSITIONS.LL],
	STATE.RWAIT : [TRANSITIONS.RL, TRANSITIONS.RL, TRANSITIONS.RR],
	STATE.RATTACK1 : [TRANSITIONS.RL, TRANSITIONS.RL, TRANSITIONS.RR],
	STATE.RATTACK2 : [TRANSITIONS.RL, TRANSITIONS.RL, TRANSITIONS.RR]
}
var transitionPathDict = {}

var newStateDict := {
	TRANSITIONS.BL : [STATE.LWAIT, STATE.LATTACK1, STATE.LATTACK2],
	TRANSITIONS.RL : [STATE.LWAIT, STATE.LATTACK1, STATE.LATTACK2],
	TRANSITIONS.LL : [STATE.LWAIT, STATE.LATTACK1, STATE.LATTACK2],
	TRANSITIONS.BR : [STATE.RWAIT, STATE.RATTACK1, STATE.RATTACK2],
	TRANSITIONS.RR : [STATE.RWAIT, STATE.RATTACK1, STATE.RATTACK2],
	TRANSITIONS.LR : [STATE.RWAIT, STATE.RATTACK1, STATE.RATTACK2],
	TRANSITIONS.BB : [STATE.BWAIT, STATE.BATTACK, STATE.BATTACK1, STATE.BATTACK2],
	TRANSITIONS.RB : [STATE.BWAIT, STATE.BATTACK, STATE.BATTACK1, STATE.BATTACK2],
	TRANSITIONS.LB : [STATE.BWAIT, STATE.BATTACK, STATE.BATTACK1, STATE.BATTACK2]
}
var stateDict := {
	STATE.BWAIT : "w",
	STATE.LWAIT : "w",
	STATE.RWAIT : "w",
	STATE.BATTACK : "a2",
	STATE.BATTACK1 : "a1",
	STATE.LATTACK1 : "a1",
	STATE.RATTACK1 : "a1",
	STATE.BATTACK2 : "a2",
	STATE.LATTACK2 : "a2",
	STATE.RATTACK2 : "a2",
}

# Timer block (should be a
var wTimer := Timer.new() # wait
var a1Timer := Timer.new() # attack 1
var a2Timer := Timer.new() # attack 2
var tTimer := Timer.new() # transition
var timers := {}
var currTimer : String

var currPath := TRANSITIONS.BB

var state := STATE.BWAIT
var next_state : STATE
var action := false

var projectile

var player
var player_inside : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	projectile = load("res://Scenes/Entities/BossProjectile.tscn")
	add_child(wTimer)
	add_child(a1Timer)
	add_child(a2Timer)
	add_child(tTimer)
	wTimer.one_shot = true
	a1Timer.one_shot = true
	a2Timer.one_shot = true
	tTimer.one_shot = true
	wTimer.wait_time = 3.0
	a1Timer.wait_time = 4.0
	a2Timer.wait_time = 4.0
	tTimer.wait_time = 0.75
	timers["w"] = wTimer
	timers["a1"] = a1Timer
	timers["a2"] = a2Timer
	timers["t"] = tTimer
	currTimer = "w"
	timers[currTimer].start()
	
	transitionPathDict = {
		TRANSITIONS.BL : path_BL,
		TRANSITIONS.BR : path_BR,
		TRANSITIONS.LB : path_LB,
		TRANSITIONS.LR : path_LR,
		TRANSITIONS.RB : path_RB,
		TRANSITIONS.RL : path_RL
	}

func get_curr_Timer_Progress():
	return 1.0 - timers[currTimer].time_left / timers[currTimer].wait_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if timers[currTimer].is_stopped():
		if state != STATE.TRANSITION:
			var transition = transitionDict[state][randi_range(0, 2)]
			next_state = newStateDict[transition][randi_range(0, len(newStateDict[transition])-1)]
			state = STATE.TRANSITION
			currTimer = "t"
			timers[currTimer].start()
			currPath = transition
		else:
			if currPath != TRANSITIONS.BB and currPath != TRANSITIONS.LL and currPath != TRANSITIONS.RR:
				transitionPathDict[currPath].progress_ratio = 1.0
				position = transitionPathDict[currPath].position
			state = next_state
			currTimer = stateDict[state]
			timers[currTimer].start()
			action = true
	if state == STATE.TRANSITION and currPath != TRANSITIONS.BB and currPath != TRANSITIONS.LL and currPath != TRANSITIONS.RR:
		transitionPathDict[currPath].progress_ratio = get_curr_Timer_Progress()
		position = transitionPathDict[currPath].position
		color_rect.color = Color(0.0, 0.0, 1.0)
	if action:
		match state:
			STATE.BATTACK:
				attackB()
				color_rect.color = Color(1.0, 0.0, 0.0)
			STATE.BATTACK1:
				attack1(0)
				color_rect.color = Color(1.0, 0.0, 0.0)
			STATE.LATTACK1:
				attack1(1)
				color_rect.color = Color(1.0, 0.0, 0.0)
			STATE.RATTACK1:
				attack1(2)
				color_rect.color = Color(1.0, 0.0, 0.0)
			STATE.BATTACK2:
				attack2(0)
				color_rect.color = Color(1.0, 0.0, 0.0)
			STATE.LATTACK2:
				attack2(1)
				color_rect.color = Color(1.0, 0.0, 0.0)
			STATE.RATTACK2:
				attack2(2)
				color_rect.color = Color(1.0, 0.0, 0.0)
			STATE.BWAIT:
				color_rect.color = Color(1.0, 1.0, 1.0)
				danger.start()
			STATE.LWAIT:
				color_rect.color = Color(1.0, 1.0, 1.0)
				danger.start()
			STATE.RWAIT:
				color_rect.color = Color(1.0, 1.0, 1.0)
				danger.start()
		action = false
	if player_inside:
		player.hit(position.x, 700.0)

func attack1(start):
	var polar_start = 0.0
	match start:
		0:
			polar_start = PI * 0.5
		1:
			polar_start = PI * 1.75
		2:
			polar_start = PI * 1.25
	
	for i in range(12):
		var rand = randf_range(-PI * 0.075, PI * 0.075)
		var r = -PI * 0.25
		while r < PI * 0.2501:
			var dir = Vector2(cos(polar_start+r+rand), sin(polar_start+r+rand))
			var bullet : Area2D = projectile.instantiate()
			bullet.position = position
			bullet.direction = dir
			get_tree().get_root().add_child(bullet)
			r += PI * 0.125
			await get_tree().create_timer(0.025).timeout

		await get_tree().create_timer(0.2).timeout


func attack2(start):
	var polar_start = 0.0
	match start:
		0:
			polar_start = PI * 0.5
		1:
			polar_start = PI * 1.75
		2:
			polar_start = PI * 1.25
	
	for i in range(6):
		var rand = randf_range(-PI * 0.075, PI * 0.075)
		var r = -PI * 0.25
		while r < PI * 0.2501:
			var dir = Vector2(cos(polar_start+r+rand), sin(polar_start+r+rand))
			var bullet : Area2D = projectile.instantiate()
			bullet.position = position
			bullet.direction = dir
			bullet.spin = true
			bullet.n_pos = position
			bullet.spin_dir = Vector2(dir.y, dir.x)
			get_tree().get_root().add_child(bullet)
			r += PI * 0.125
			await get_tree().create_timer(0.025).timeout

		await get_tree().create_timer(0.3).timeout

func attackB():
	var r = 0.0
	for j in range(118):
		var dir = Vector2(0.0, 1.0)
		var bullet : Area2D = projectile.instantiate()
		bullet.position = Vector2(r-640.0, -360.0)
		bullet.direction = dir
		get_tree().get_root().add_child(bullet)
		r = fmod(r+120.0, 1280.0)
		await get_tree().create_timer(0.03).timeout

func hit():
	health -= 1
	if health <= 0:
		GlobalSignals.emit_signal("BossT")
		queue_free()
	GlobalSignals.emit_signal("UpdateBossHealth", health)

func _on_danger_timeout():
	color_rect.color = Color(1.0, 0.3, 0.0)


func _on_body_entered(body):
	if body.name == "Player":
		player = body
		player_inside = true


func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
