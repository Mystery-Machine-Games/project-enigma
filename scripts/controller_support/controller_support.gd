extends Node

@export var sensitivity: float = 10.0
@export var joy_deadzone: float = 0.2

func _process(_delta: float) -> void:
	var cursor_velocity: Vector2 = Input.get_vector(
		"cursor_left",
		"cursor_right",
		"cursor_up",
		"cursor_down",
		joy_deadzone
	) * sensitivity
	var viewport: Viewport = get_viewport()
	
	viewport.warp_mouse(viewport.get_mouse_position() + cursor_velocity)
