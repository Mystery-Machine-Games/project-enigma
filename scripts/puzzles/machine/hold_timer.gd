extends Label3D

func _on_button_held(time_down: float) -> void:
	text = "%.1f s" % time_down

func _on_reset_display(_button: Node, _time_down: float) -> void:
	text = "0.0 s"
