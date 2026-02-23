extends Node

var camera_index: int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera"):
		camera_index = 1 if camera_index == 0 else 0
		var camera: Camera3D = get_child(camera_index)
		camera.make_current()