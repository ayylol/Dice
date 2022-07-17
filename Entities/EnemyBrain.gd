extends Node

var _pattern = [0,0,0]
var in_turn = false
var _move_index = 0
var _times_tried = 0
var _last_move_failed = false
var _tried_flipped = false
var _chasing_player = true

onready var die = $".."

func _ready():
	new_pattern()

func new_pattern():
	_tried_flipped = false
	_move_index = 0
	_times_tried = 0
	var ok_moves = [randi()%2, (randi()%2)+2]
	randomize()
	for i in range(_pattern.size()):
		_pattern[i] = ok_moves[randi()%ok_moves.size()]
	print(_pattern)

func flip_pattern():
	_tried_flipped = true
	_move_index = 0
	_times_tried = 0
	_pattern.invert()
	for i in range(_pattern.size()):
		_pattern[i] = Directions.get_opposite(_pattern[i])
	print(_pattern)

func get_move():
	_move_index = (_move_index + 1) % _pattern.size()
	var move = _pattern[_move_index]
	return move

func _on_Dice_attacked():
	if in_turn:
		die.move(get_move())

func _on_Dice_failed_to_move():
	if in_turn:
		if _times_tried <= 3:
			_times_tried +=1
			die.move(get_move())
		elif not _tried_flipped:
			flip_pattern()
			die.move(get_move())	
		else:
			new_pattern()
			die.move(get_move())

func _on_Dice_moved():
	if in_turn:
		die.move(get_move())
		_tried_flipped = false

func _on_Dice_turn_done():
	in_turn = false

func _on_Dice_turn_started():
	in_turn = true
	die.move(get_move())
