extends KinematicBody

enum Direction {
	FORWARDS,
	BACKWARDS,
	LEFT,
	RIGHT
}

export var move_time = 0.25
export var jump_apex = 10

var _can_move = true

onready var rot_tween = $RotateTween
onready var jump_anim = $AnimationPlayer
onready var mesh = $MeshRoot/Mesh
onready var mesh_root = $MeshRoot

func move(direction):
	var initiate = false
	var trans_to = Transform(mesh.transform.basis)
	match direction:
		Direction.FORWARDS:
			trans_to = trans_to.rotated(Vector3(1,0,0), -PI/2)
			initiate = true
		Direction.BACKWARDS:
			trans_to = trans_to.rotated(Vector3(1,0,0), PI/2)
			initiate = true
		Direction.LEFT:
			trans_to = trans_to.rotated(Vector3(0,0,1), PI/2)
			initiate = true
		Direction.RIGHT:
			trans_to = trans_to.rotated(Vector3(0,0,1), -PI/2)
			initiate = true
	if _can_move and initiate:
		jump_anim.play("move")
		rot_tween.interpolate_property(
			mesh, "transform", 
			mesh.transform, trans_to, 
			move_time, rot_tween.TRANS_SINE, rot_tween.EASE_IN_OUT)
		rot_tween.start()
		_can_move = false

func _on_RotateTween_tween_step(object, key, elapsed, value):
	mesh.transform = mesh.transform.orthonormalized()

func _on_RotateTween_tween_all_completed():
	_can_move = true


func _on_JumpTween_tween_started(object, key):
	print("pissshit")
