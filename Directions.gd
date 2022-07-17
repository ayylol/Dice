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
