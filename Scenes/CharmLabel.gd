extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.connect("CharmPickup", _on_charm_pickup)

func _on_charm_pickup(charm: String):
	text += "\n" + charm
