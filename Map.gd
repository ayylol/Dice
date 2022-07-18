extends GridMap

signal next_level

export var start_pos = Vector2(0,0)

var players
var current_player

func _ready():
	players = get_tree().get_nodes_in_group("Die")#= get_children()
	for player in players:
		player.connect("turn_done", self, "next_turn")
		player.connect("moved", self, "players_moved")
	current_player = players.find($Player)
	$Player.teleport(start_pos)
	players[current_player].start_turn()
	players_moved()

func is_occupied(grid_pos: Vector2):
	for dice in get_children():
		if is_instance_valid(dice) and (dice.get("grid_pos") == grid_pos):
			return dice
	return null

func next_turn():
	var last_player = players[current_player]
	players = get_tree().get_nodes_in_group("Die")
	current_player = (players.find(last_player)+1)%players.size()
	players[current_player].start_turn()
	
func players_moved():
	for p in players:
		if not is_instance_valid(p) or p.is_in_group("Friendly") or p.is_in_group("Pickup"):
			continue
		p.get_node("Brain").should_show_health()

func _on_Player_got_to_end():
	emit_signal("next_level")

func _physics_process(delta):
	pass
	#print(current_player)
