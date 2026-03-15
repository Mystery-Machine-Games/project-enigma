extends Label3D

func _process(_delta: float) -> void:
	text = ("Press '%s' to view your solved jigsaws." %
		InputMap.get_action_description("toggle_clue").get_slice(" ", 0)
	)
	text += ("\nPress '%s' to cycle between button/wire view." %
		InputMap.get_action_description("cycle_focus_view").get_slice(" ", 0)
	)
