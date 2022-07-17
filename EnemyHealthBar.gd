extends Spatial

onready var progress_bar = $Viewport/ProgressBar
onready var label = $Viewport/ProgressBar/Label

func _on_Dice_health_changed(health, max_health):
	progress_bar.max_value = max_health
	progress_bar.value = health
	label.text = String(health) + "/" + String(max_health)
	
