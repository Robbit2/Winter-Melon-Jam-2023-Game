extends Label

@onready var health_label = $"."

func update(_text):
	text = str(_text)
	health_label.text = text
