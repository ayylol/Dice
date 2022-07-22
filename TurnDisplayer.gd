extends Label

export(NodePath) var node_path
onready var playerNode = get_node(node_path) 
# Called when the node enters the scene tree for the first time.
func _process(delta):
	text = "TURNS USED: "+str(playerNode._turn_ended)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
