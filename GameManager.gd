extends Spatial

var next_stage = 0
const STAGES = [
	preload("res://map/Map1.tscn"),
	preload("res://map/Map2.tscn"),
	preload("res://map/Map3.tscn"),
]
var current_stage

func _ready():
	get_next_stage()

func get_next_stage():
	if next_stage == STAGES.size():
		print("WON!")
		next_stage = 0
	if is_instance_valid(current_stage): 
		current_stage.queue_free()
	current_stage = STAGES[next_stage].instance()
	add_child(current_stage)
	current_stage.connect("next_level", self, "_on_Player_got_to_end")


func _on_Player_got_to_end():
	next_stage +=1
	get_next_stage()
