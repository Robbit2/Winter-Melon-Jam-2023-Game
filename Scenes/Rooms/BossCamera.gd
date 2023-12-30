extends Node2D

@onready var bosscam = $BossCam

# Called when the node enters the scene tree for the first time.
func _ready():
	bosscam.make_current()
