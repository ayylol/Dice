extends KinematicBody

signal turn_done

export var max_health = 10
export var move_time = 0.25
export var grid_step_size = 1
export var jump_apex = 10
export var height_offset = 2
export var starting_pos = Vector2(0,0)

var instant_move = false

var _moves_left = 0
var _has_attacked = false
var _can_move = true

onready var health = max_health
onready var grid_pos = starting_pos

onready var grid = $".."
onready var move_tween = $MoveTween
onready var jump_anim = $JumpAnimation
onready var mesh = $MeshRoot/Mesh
onready var mesh_root = $MeshRoot
onready var offset = Vector3(0,height_offset,0)

func _ready():
	transform.origin = grid.map_to_world(starting_pos.x, 0, starting_pos.y) + offset

func move(direction):
	var initiate = false
	var trans_to = Transform(mesh.transform.basis)
	var _temp_grid_pos = grid_pos
	var move_to = transform
	if _can_move and _moves_left > 0:
		# Get possible movement
		match direction:
			Directions.FORWARD:
				trans_to = trans_to.rotated(Vector3(1,0,0), -PI/2)
				_temp_grid_pos += Vector2(0,-grid_step_size)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
			Directions.BACKWARD:
				trans_to = trans_to.rotated(Vector3(1,0,0), PI/2)
				_temp_grid_pos += Vector2(0,grid_step_size)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
			Directions.LEFT:
				trans_to = trans_to.rotated(Vector3(0,0,1), PI/2)
				_temp_grid_pos += Vector2(-grid_step_size,0)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
			Directions.RIGHT:
				trans_to = trans_to.rotated(Vector3(0,0,1), -PI/2)
				_temp_grid_pos += Vector2(grid_step_size,0)
				move_to = grid.map_to_world(_temp_grid_pos.x, 0, _temp_grid_pos.y) + offset
				initiate = true
		# Perform movement
		var next_tile = grid.get_cell_item(_temp_grid_pos.x, 0, _temp_grid_pos.y)
		if initiate and not (next_tile == -1 or next_tile == 1 or next_tile == 2 or next_tile == 3):
			var on_next_tile = grid.is_occupied(_temp_grid_pos)
			if on_next_tile != null:
				if on_next_tile.is_in_group("Enemy"): # Attack
					if not _has_attacked:
						on_next_tile.damage(get_side(direction).val)
						_has_attacked = true
						_did_move()
					return
				elif on_next_tile.is_in_group("Pickup"): # Move and pickup
					print("pickup")
			
			if instant_move:
				mesh.transform = trans_to
				transform = Transform(transform.basis, move_to)
				_did_move()
				return
				
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
			_can_move = false
			grid_pos = _temp_grid_pos
			_did_move()

func _on_RotateTween_tween_step(object, key, elapsed, value):
	mesh.transform = mesh.transform.orthonormalized()

func _on_RotateTween_tween_all_completed():
	_can_move = true

func damage(amount: int):
	health -= amount
	if health<=0:
		queue_free()
	print(health)

func _did_move():
	print("moved")
	_moves_left -= 1
	if _moves_left <= 0:
		emit_signal("turn_done")

func start_turn():
	_moves_left = get_side(Directions.TOP).val
	_has_attacked = false

func get_side(direction):
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
	static func top_most(a, b) -> bool:
		return a.get_node("Tip").global_transform.origin.y > b.get_node("Tip").global_transform.origin.y
	static func bottom_most(a, b) -> bool:
		return a.global_transform.origin.y < b.global_transform.origin.y
	
	static func left_most(a, b) -> bool:
		return a.get_node("Tip").global_transform.origin.x < b.get_node("Tip").global_transform.origin.x
	static func right_most(a, b ) -> bool:
		return a.get_node("Tip").global_transform.origin.x > b.get_node("Tip").global_transform.origin.x
	
	static func front_most(a, b) -> bool:
		return a.get_node("Tip").global_transform.origin.z < b.get_node("Tip").global_transform.origin.z
	static func back_most(a, b) -> bool:
		return a.get_node("Tip").global_transform.origin.z > b.get_node("Tip").global_transform.origin.z
