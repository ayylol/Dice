extends Spatial

export var grid_pos = Vector2(1,1)

export var height_offset = 2
onready var offset = Vector3(0,height_offset,0)
onready var grid = $".."

func teleport():
	transform = Transform(transform.basis, grid.map_to_world(grid_pos.x, 0, grid_pos.y) + offset)
