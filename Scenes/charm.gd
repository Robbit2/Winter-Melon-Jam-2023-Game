extends Area2D

@onready var right = $Right
@onready var left = $Left

@onready var charm = $"."
@onready var player = $"../Player"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if right.is_colliding():
		charm.position.x = move_toward(charm.position.x, player.position.x, .5)
	if left.is_colliding():
		charm.position.x = move_toward(charm.position.x, player.position.x, .5)

func _on_body_entered(_body):
	queue_free()
	player.charms += 1
