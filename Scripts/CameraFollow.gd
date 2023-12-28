extends Camera2D

@export var follow_speed : float = 15.0

func _ready():
	position = get_parent().position

func _physics_process(delta):
	position = lerp(position, get_parent().position, follow_speed * delta)
