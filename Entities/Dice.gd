extends KinematicBody

export var move_time = 0.25
export var jump_apex = 10
export var height_offset = 2
export var starting_pos = Vector2(0,0)

var grid_pos = starting_pos

var _can_move = true

onready var grid = $".."
onready var move_tween = $MoveTween
onready var jump_anim = $JumpAnimation
onready var mesh = $MeshRoot/Mesh
onready var mesh_root = $MeshRoot
onready var offset = Vector3(0,height_offset,0)

func _ready():
	transform.origin = grid.map_to_world(starting_pos.x, starting_pos.y, 0) + offset

func move(direction):
	var initiate = false
	var trans_to = Transform(mesh.transform.basis)
	var _temp_grid_pos = grid_pos
	var move_to = transform
	if _can_move:
		match direction:
			Directions.FORWARD:
				trans_to = trans_to.rotated(Vector3(1,0,0), -PI/2)
				_temp_grid_pos += Vector2(0,-1)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
			Directions.BACKWARD:
				trans_to = trans_to.rotated(Vector3(1,0,0), PI/2)
				_temp_grid_pos += Vector2(0,1)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
			Directions.LEFT:
				trans_to = trans_to.rotated(Vector3(0,0,1), PI/2)
				_temp_grid_pos += Vector2(-1,0)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
			Directions.RIGHT:
				trans_to = trans_to.rotated(Vector3(0,0,1), -PI/2)
				_temp_grid_pos += Vector2(1,0)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
	if _can_move and initiate and grid.get_cell_item(_temp_grid_pos.x, 0, _temp_grid_pos.y) != -1:
		jump_anim.play("move")
		
		move_tween.interpolate_property(
			mesh, "transform", 
			mesh.transform, trans_to, 
			move_time, move_tween.TRANS_SINE, move_tween.EASE_IN_OUT)
			
		move_tween.interpolate_property(
			$".", "transform",
			transform, Transform(transform.basis, move_to),
			move_time, move_tween.TRANS_SINE, move_tween.EASE_IN_OUT)
		move_tween.start()
		grid_pos = _temp_grid_pos
		_can_move = false

func _on_RotateTween_tween_step(object, key, elapsed, value):
	mesh.transform = mesh.transform.orthonormalized()

func _on_RotateTween_tween_all_completed():
	_can_move = true

func get_side(direction) -> Spatial:
	var sides = mesh.get_children()
	match direction:
		Directions.FORWARD:
			sides.sort_custom(sorter, "front_most")
		Directions.BACKWARD:
			sides.sort_custom(sorter, "back_most")
		Directions.LEFT:
			sides.sort_custom(sorter, "left_most")
		Directions.RIGHT:
			sides.sort_custom(sorter, "right_most")
		Directions.TOP:
			sides.sort_custom(sorter, "top_most")
		Directions.BOTTOM:
			sides.sort_custom(sorter, "bottom_most")
	return sides[0]
	
class sorter:
	static func top_most(a : Spatial, b : Spatial) -> bool:
		return a.global_transform.origin.y > b.global_transform.origin.y
	static func bottom_most(a : Spatial, b : Spatial) -> bool:
		return a.global_transform.origin.y < b.global_transform.origin.y
	
	static func left_most(a : Spatial, b : Spatial) -> bool:
		return a.global_transform.origin.x < b.global_transform.origin.x
	static func right_most(a : Spatial, b : Spatial) -> bool:
		return a.global_transform.origin.x > b.global_transform.origin.x
	
	static func front_most(a : Spatial, b : Spatial) -> bool:
		return a.global_transform.origin.z < b.global_transform.origin.z
	static func back_most(a : Spatial, b : Spatial) -> bool:
		return a.global_transform.origin.z > b.global_transform.origin.z
