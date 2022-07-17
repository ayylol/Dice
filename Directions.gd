extends Node

enum {
	FORWARD,
	BACKWARD,
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

func get_opposite(dir):
	match dir:
		FORWARD:
			return BACKWARD
		BACKWARD:
			return FORWARD
		LEFT:
			return RIGHT
		RIGHT:
			return LEFT
		TOP:
			return BOTTOM
		BOTTOM:
			return TOP
	return -1

func vec2_to_dir(dir: Vector2):
	match dir.normalized():
		Vector2(1,0):
			return RIGHT
		Vector2(-1,0):
			return LEFT
		Vector2(0,1):
			return BACKWARD
		Vector2(0,-1):
			return FORWARD
	return -1
