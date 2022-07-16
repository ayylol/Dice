extends Spatial

export var rot_time = 0.35

var current_fwd = 0
var _dirs = [
	Directions.FORWARD,
	Directions.RIGHT,
	Directions.BACKWARD,
	Directions.LEFT
	]
var _can_move_cam = true

onready var die = $".."
onready var rot_tween = $Rotate

func _input(event):
	if event.is_action("forwards"):
		die.move(_dirs[current_fwd])
	if event.is_action("right"):
		die.move(_dirs[(current_fwd+1)%_dirs.size()])
	if event.is_action("backwards"):
		die.move(_dirs[(current_fwd+2)%_dirs.size()])
	if event.is_action("left"):
		die.move(_dirs[(current_fwd+3)%_dirs.size()])
	
	if event.is_action("ui_left"):
		rotate_cam(Directions.LEFT)
	if event.is_action("ui_right"):
		rotate_cam(Directions.RIGHT)

func rotate_cam(direction):
	if _can_move_cam:
		var rotate = false
		var final_rot = $".".rotation
		var direction_change = 0
		match direction:
			Directions.LEFT:
				final_rot += Vector3(0,PI/2,0)
				direction_change= -1
				rotate = true
			Directions.RIGHT:
				final_rot += Vector3(0,-PI/2,0)
				direction_change = 1
				rotate = true
		if rotate:
			current_fwd = (current_fwd+direction_change)%_dirs.size()
			rot_tween.interpolate_property(
				$".", "rotation",
				$".".rotation, final_rot,
				rot_time, rot_tween.TRANS_SINE, rot_tween.EASE_IN_OUT)
			rot_tween.start()
			_can_move_cam = false

func _on_Rotate_tween_all_completed():
	_can_move_cam = true
