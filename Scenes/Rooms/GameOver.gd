extends CanvasLayer

@onready var end_panel = $EndPanel
@onready var boss_health_panel = $BossHealthPanel
@onready var health_panel = $HealthPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.connect("BossT", _on_defeat)


func _on_defeat():
	end_panel.visible = true
	boss_health_panel.visible = false
	health_panel.visible = false
