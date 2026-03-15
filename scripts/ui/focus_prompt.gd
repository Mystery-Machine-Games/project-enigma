extends Label3D

func _process(_delta: float) -> void:
	text = ("Press '%s' while pointing at a puzzle to focus on it. Press '%s' to unfocus." % [
		InputMap.get_action_description("focus_item").get_slice(" ", 0),
		InputMap.get_action_description("unfocus_item").get_slice(" ", 0),
	])
