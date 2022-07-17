extends Node

export var turns_to_forget = 2
export var awareness_range = 8

var _in_turn = false
var _pattern = [0,0,0]
var _move_index = 0
var _times_tried = 0
var _last_move_failed = false
var _tried_flipped = false
var _chasing_player = true
var _turns_since_seen = 10000
var _path_to_player

onready var die = $".."
var health_bar
var health_tween

func _ready():
	new_pattern()
	
	health_bar = $"../MeshRoot/Healthbar"
	health_tween = $"../MeshRoot/Healthbar/HealthTween"

func new_pattern():
	_tried_flipped = false
	_move_index = 0
	_times_tried = 0
	var ok_moves = [randi()%2, (randi()%2)+2]
	randomize()
	for i in range(_pattern.size()):
		_pattern[i] = ok_moves[randi()%ok_moves.size()]

func flip_pattern():
	_tried_flipped = true
	_move_index = 0
	_times_tried = 0
	_pattern.invert()
	for i in range(_pattern.size()):
		_pattern[i] = Directions.get_opposite(_pattern[i])

func get_move():
	_move_index = (_move_index + 1) % _pattern.size()
	var move = _pattern[_move_index]
	return move

# FOR PATHFINDING
func get_path_to_player():
	# [NODE, F, G, H PARENT]
	var _origin_h = heuristic(die.grid_pos)
	var open_list = [[die.grid_pos, _origin_h, 0, _origin_h, null]] # Lower f goes at back of array
	var closed_list = []
	var adj = [Vector2(0,-1),Vector2(0,1),Vector2(-1,0),Vector2(1,0)]
	while not open_list.empty():
		var q = open_list.pop_back()
		for s in adj:
			var side =  q[0] + s
			if die.grid.get_cell_item(side.x,0,side.y) == 0: # open cell
				var node = [side, 0, q[2]+1, 0, q]
				var tile_content = die.grid.is_occupied(side)
				if tile_content != null and tile_content.is_in_group("Friendly"):
					return node
				node[3] = heuristic(side)
				node[1] = node[2] + node[3]
				var _check_if_in_list = node_already_visited(open_list, node)
				if _check_if_in_list!=null and _check_if_in_list[1]<node[1]:
					continue
				elif node_already_visited(closed_list, node)!=null:
					continue
				else:
					var placed = false
					for i in range(open_list.size()):
						if node[1] > open_list[i][1]:
							placed = true
							open_list.insert(i,node)
							break
					if not placed:
						open_list.push_back(node)
		closed_list.push_back(q)
	return null

func node_already_visited(list, node):
	for n in list:
		if n[0] == node[0]: return n
	return null

func heuristic(pos: Vector2)->float:
	return die.grid.get_node("Player").grid_pos.distance_to(pos)
#END FOR PATHFINDING

func _on_Dice_attacked():
	if _in_turn:
		die.move(get_move())

func back_trace(node):
	if node != null:
		var current_node = node
		var next_node = current_node[4]
		var path = []
		while next_node != null:
			path.push_back(Directions.vec2_to_dir(current_node[0]-next_node[0]))
			current_node = next_node
			next_node = current_node[4]
		return path
	return []

func _on_Dice_failed_to_move():
	if _in_turn:
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
	if _in_turn:
		if _chasing_player:
			if _path_to_player.size() <= 0:
				_chasing_player = false
				die.move(get_move())
			die.move(_path_to_player.pop_back())
		else:
			die.move(get_move())
			_tried_flipped = false

func _on_Dice_turn_done():
	_in_turn = false

func _on_Dice_turn_started():
	_in_turn = true
	if(heuristic(die.grid_pos)<awareness_range):
		_turns_since_seen = 0
	else:
		_turns_since_seen += 1
	
	if _turns_since_seen < turns_to_forget:
		_path_to_player = back_trace(get_path_to_player())
		if _path_to_player.size() <= 0:
			_chasing_player = false
			die.move(get_move())
		die.move(_path_to_player.pop_back())
		_chasing_player = true
	else:
		_chasing_player = false
		die.move(get_move())

func should_show_health():
	var h = heuristic(die.grid_pos)
	die.instant_move = false
	if h < 10:
		var s = clamp(4/(h+2),0.2,1)
		health_tween.stop_all()
		health_tween.interpolate_property(
			health_bar, "scale",
			health_bar.scale, Vector3(s,s,s),
			0.1)
		health_tween.start()
		health_bar.show()
	else:
		health_bar.hide()
	if h > 20:
		die.instant_move = true
