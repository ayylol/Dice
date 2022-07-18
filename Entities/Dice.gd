extends KinematicBody

signal turn_done
signal turn_started
signal failed_to_move
signal moved
signal attacked
signal health_changed(health, max_health)
signal game_over
signal got_to_end

export var max_health = 10
export var move_time = 0.25
export var grid_step_size = 1
export var jump_apex = 10
export var height_offset = 2
export var starting_pos = Vector2(0,0)

onready var grid_pos = starting_pos
var instant_move = false

var _moves_left = 0
var _has_attacked = false
var _can_move = true
var _hit_dir
var _hit_strength
var _hit_target

onready var health = max_health


onready var grid = $".."
onready var move_tween = $MoveTween
onready var jump_anim = $JumpAnimation
onready var mesh = $MeshRoot/Mesh
onready var mesh_root = $MeshRoot
onready var hammer_root = $MeshRoot/HammerRoot
onready var hammer = $MeshRoot/HammerRoot/Hammer
onready var hit_anim = $MeshRoot/HammerRoot/Hammer/HitAnimation
onready var step_audio = $StepAudio
onready var hit_audio = $HitAudio
onready var offset = Vector3(0,height_offset,0)

const STEPS = {
	0: preload("res://Entities/Assets/Move Dice 1.wav"),
	1: preload("res://Entities/Assets/Move Dice 2.wav"),
	2: preload("res://Entities/Assets/Move Dice 3.wav"),
	3: preload("res://Entities/Assets/Move Dice 4.wav"),
	4: preload("res://Entities/Assets/Move Dice 5.wav"),
}

const HITS = {
	0: preload("res://Entities/Assets/Hit 1.wav"),
	1: preload("res://Entities/Assets/Hit 2.wav"),
	2: preload("res://Entities/Assets/Hit 3.wav"),
	3: preload("res://Entities/Assets/Hit 4.wav"),
	4: preload("res://Entities/Assets/Hit 5.wav"),
	5: preload("res://Entities/Assets/Hit 6.wav"),
}

func _ready():
	
	transform.origin = grid.map_to_world(starting_pos.x, 0, starting_pos.y) + offset
	emit_signal("health_changed", health, max_health)

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
		if initiate and not (next_tile == -1 or next_tile == 3 or next_tile == 4):
			var on_next_tile = grid.is_occupied(_temp_grid_pos)
			if on_next_tile != null:
				if on_next_tile.is_in_group("Die"):
					if (((is_in_group("Friendly") and on_next_tile.is_in_group("Enemy"))
						or (is_in_group("Enemy") and on_next_tile.is_in_group("Friendly")))
						and (not _has_attacked)): # Attack
							_hit_dir = direction
							_hit_target = on_next_tile
							_hit_strength = get_side(_hit_dir).val
							hammer_root.show()
							hammer_root.rotation.y = Directions.dir_to_rad(_hit_dir) + PI
							hit_anim.play("Hit")
							_can_move = false
					else:
						emit_signal("failed_to_move")
					return
				elif on_next_tile.is_in_group("Pickup") and is_in_group("Friendly"): # Move and pickup
					var new_side = on_next_tile.get_node("Mesh")
					on_next_tile.remove_child(new_side)
					mesh.add_child(new_side)
					var to_replace = get_side(direction)
					new_side.transform = to_replace.transform
					on_next_tile.queue_free()
					to_replace.queue_free()
					print("pickups")
			
			if instant_move:
				mesh.transform = trans_to
				transform = Transform(transform.basis, move_to)
				_did_move()
				emit_signal("moved")
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
		else:
			emit_signal("failed_to_move")

func _on_RotateTween_tween_step(object, key, elapsed, value):
	mesh.transform = mesh.transform.orthonormalized()

func _on_RotateTween_tween_all_completed():
	_can_move = true
	emit_signal("moved")
	play_step()
	if is_in_group("Friendly") and grid.get_cell_item(grid_pos.x, 0, grid_pos.y)==2:
		emit_signal("got_to_end")

func damage(amount: int):
	health -= amount
	if health <= 0:
		if is_in_group("Friendly"):
			_can_move = false
			emit_signal("game_over")
		else:
			queue_free()
	emit_signal("health_changed", health, max_health)

func _did_move():
	_moves_left -= 1
	if _moves_left <= 0:
		emit_signal("turn_done")

func start_turn():
	_moves_left = get_side(Directions.TOP).val
	_has_attacked = false
	emit_signal("turn_started")

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

func _on_HitAnimation_animation_finished(anim_name):
	hammer_root.hide()
	_has_attacked = true
	_can_move = true
	_did_move()
	emit_signal("attacked")

func play_hit():
	_hit_target.damage(_hit_strength)
	hit_audio.set_stream(HITS[_hit_strength-1])
	hit_audio.play()

func play_step():
	var step_index = randi() % STEPS.size()
	step_audio.set_stream(STEPS[step_index])
	step_audio.set_pitch_scale(rand_range(0.8, 1.2))
	step_audio.play()
	
func teleport(pos):
	grid_pos = pos
	transform = Transform(transform.basis, grid.map_to_world(grid_pos.x, 0, grid_pos.y) + offset)

func end_turn():
	_can_move = false
	_moves_left = 0
	emit_signal("turn_done")

