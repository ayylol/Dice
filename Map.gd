extends GridMap

var players
var current_player

func _ready():
	players = get_children()
	for player in players:
		player.connect("turn_done", self, "next_turn")
	current_player = players.find($Player)
	players[current_player].start_turn()

func is_occupied(grid_pos: Vector2):
	for dice in get_children():
		if dice.get("grid_pos") == grid_pos:
			return dice
	return null
	

func next_turn():
	current_player = (current_player+1)%players.size()
	players[current_player].start_turn()
