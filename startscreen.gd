extends Node2D


# Called when the node enters the scene tree for the first time.
func _on_start_button_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")
