extends Area2D

## set by enemy
var direction : float
@export var PROJECTILE_SPEED : float = 500.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x += direction * PROJECTILE_SPEED * delta


func _on_area_entered(area):
	if "Player" not in area.name and "Projectile" not in area.name:
		if "Enemy" in area.name:
			area.die()
		queue_free()

func _on_lifetime_timeout():
	queue_free()
