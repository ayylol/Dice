extends ProgressBar

onready var label = $Label

func _on_Player_health_changed(health, max_health):
	max_value = max_health
	value = health
	label.text = String(health) + "/" + String(max_health)
	
