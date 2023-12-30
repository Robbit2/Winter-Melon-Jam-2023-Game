extends Button


# Called when the node enters the scene tree for the first time.

@onready var player = $"../../../Player"




func _on_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

