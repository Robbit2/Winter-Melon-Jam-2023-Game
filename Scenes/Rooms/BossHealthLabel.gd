extends Label

func _ready():
	GlobalSignals.connect("UpdateBossHealth", _on_update_health)

func _on_update_health(health: int):
	text = "Boss Health: " + str(health)
