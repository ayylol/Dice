extends Node

onready var die = $".."

func _input(event):
	if event.is_action_pressed("forwards"):
		die.move(die.Direction.FORWARDS)
	if event.is_action_pressed("backwards"):
		die.move(die.Direction.BACKWARDS)
	if event.is_action_pressed("left"):
		die.move(die.Direction.LEFT)
	if event.is_action_pressed("right"):
		die.move(die.Direction.RIGHT)
