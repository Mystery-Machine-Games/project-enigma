extends Label3D

func _process(_delta: float) -> void:
	text = ("Press '%s' to view your solved jigsaws" %
		InputMap.get_action_description("toggle_clue")
	)
