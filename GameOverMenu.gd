extends Control

func _on_PlayAgainButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn") # Replace with function body.

func _on_QuitGOButton_pressed():
	get_tree().quit() # Replace with function body.


func _on_Player_game_over():
	show()

