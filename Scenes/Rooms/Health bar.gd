extends ColorRect

@onready var bar = $"."
@onready var boss = $"../../../Boss"

func _ready():
	GlobalSignals.connect("UpdateBossHealth", update_width)

func update_width():
	var width : int = (boss.health / 15) * 300
	bar.transform.size.x = width
