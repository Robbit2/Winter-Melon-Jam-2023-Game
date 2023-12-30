extends Area2D

## set by enemy
var direction : float
@export var PROJECTILE_SPEED : float = 500.0
@export var knockback : float = 200.0
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x += direction * PROJECTILE_SPEED * delta

# alternative projectile hitbox detection
func _on_body_shape_entered(_body_rid, body, body_shape_index, _local_shape_index):
	if body.name == "Player" and body_shape_index == 1:
		body.hit(position.x, knockback)
		queue_free()
	if body.name != "Player":
		queue_free()
