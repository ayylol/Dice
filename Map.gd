extends GridMap

var players
var current_player

func _ready():
	players = get_children()
	for player in players:
		player.connect("turn_done", self, "next_turn")
		player.connect("moved", self, "players_moved")
	current_player = players.find($Player)
	players[current_player].start_turn()
	players_moved()
	

func is_occupied(grid_pos: Vector2):
	for dice in get_children():
		if dice.get("grid_pos") == grid_pos:
			return dice
	return null

func next_turn():
	var last_player = players[current_player]
	players = get_children()
	current_player = (players.find(last_player)+1)%players.size()
	players[current_player].start_turn()
	
func players_moved():
	for p in players:
		if is_instance_valid(p) and p.is_in_group("Friendly"):
			continue
		p.get_node("Brain").should_show_health()
