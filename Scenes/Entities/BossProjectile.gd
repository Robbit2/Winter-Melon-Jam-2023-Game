extends Area2D

## set by enemy
var direction : Vector2
var spin := false
var spin_offset := 0.0
var spin_dir : Vector2
var n_pos : Vector2
@export var PROJECTILE_SPEED : float = 500.0
@export var knockback : float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	GlobalSignals.connect("Died", _remove_projectile)
	spin_offset = randf_range(0.0, PI*2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not spin:
		position += direction * PROJECTILE_SPEED * delta
	else:
		n_pos += direction * PROJECTILE_SPEED * delta
		position = n_pos + spin_dir * sin(spin_offset * PI * 2.0) * 32
		spin_offset += delta

# alternative projectile hitbox detection
func _on_body_shape_entered(_body_rid, body, body_shape_index, _local_shape_index):
	if body.name == "Player" and body_shape_index == 1:
		body.hit(position.x, knockback)
		queue_free()


func _on_lifetime_timeout():
	queue_free()

func _remove_projectile():
	queue_free()
