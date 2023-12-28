extends Area2D

## set by enemy
var direction : float
@export var PROJECTILE_SPEED : float = 500.0
@export var knockback : float = 200.0
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x += direction * PROJECTILE_SPEED * delta


func _on_body_entered(body):
	# I don't like this, but if we don't change the name it works
	if body.name == "Player":
		body.hit(position.x, knockback)
	queue_free()
