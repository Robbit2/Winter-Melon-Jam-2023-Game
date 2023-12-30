extends Button


# Called when the node enters the scene tree for the first time.

@onready var player = $"../../../Player"

func _on_pressed():
		get_tree().reload_current_scene()
		Engine.time_scale = 1

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
