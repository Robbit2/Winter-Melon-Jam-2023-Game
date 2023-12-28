extends Button

@onready var player = $"../../../Player"

func _on_pressed():
	if player.dead:
		get_tree().reload_current_scene()
		Engine.time_scale = 1
