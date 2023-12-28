extends Camera2D

@export var follow_speed : float = 20.0
@export var y_offset : float = 100.0

func _ready():
	position = get_parent().position + Vector2(0.0, -y_offset)

func _physics_process(delta):
	position = lerp(position, get_parent().position + Vector2(0.0, -y_offset), follow_speed * delta)
