extends Node

func _physics_process(delta):
	$"..".move(Directions.RIGHT)
	$"..".move(Directions.LEFT)
