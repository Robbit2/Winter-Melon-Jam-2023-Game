extends Label

@onready var health_label = $"."

func _ready():
	GlobalSignals.connect("UpdateHealth", _on_update_health)

func _on_update_health(health: int):
	health_label.text = "Health: " + str(health)
