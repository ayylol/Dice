extends Node

var _pattern = [0,0,0]
var _move_index = 0
var _tried_flipped = false

func _ready():
	new_pattern()
	
func new_pattern():
	_tried_flipped = false
	_move_index = 0
	var ok_moves = [randi()%2, (randi()%2)+2]
	randomize()
	for i in range(_pattern.size()):
		_pattern[i] = ok_moves[randi()%ok_moves.size()]
	print(_pattern)

func flip_pattern():
	_move_index = 0
	_tried_flipped = true
	var temp = Array(_pattern)
	for i in range(temp.size()):
		var dir = temp[i]
		var new_dir = 0
		match dir:
			Directions.RIGHT:
				new_dir = Directions.LEFT
			Directions.LEFT:
				new_dir = Directions.RIGHT
			Directions.FORWARD:
				new_dir = Directions.BACKWARD
			Directions.BACKWARD:
				new_dir = Directions.FORWARD
		_pattern[_pattern.size()-1-i] = new_dir
	print(_pattern)

func get_move():
	var move = _pattern[_move_index]
	_move_index = (_move_index + 1) % _pattern.size()
	return move

func _on_Dice_attacked():
	pass # Replace with function body.

func _on_Dice_failed_to_move():
	if $".."._moves_left > 0:
		if not _tried_flipped and _move_index == 3:
			flip_pattern()
		else:
			new_pattern()
		$"..".move(get_move())

func _on_Dice_moved():
	$"..".move(get_move())

func _on_Dice_turn_done():
	pass # Replace with function body.

func _on_Dice_turn_started():
	$"..".move(get_move())
