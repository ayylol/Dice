extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_MainMenuWinButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")

func _on_QuitWinButton_pressed():
	get_tree().quit() # Replace with function body.
