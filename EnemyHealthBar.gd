extends Spatial

onready var progress_bar = $Viewport/ProgressBar

func _on_Dice_health_changed(health, max_health):
	progress_bar.max_value = max_health
	progress_bar.value = health
