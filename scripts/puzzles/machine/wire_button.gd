class_name WireButton
extends TextureButton

@export var wire_type: String

signal wire_changed


func _input(event: InputEvent) -> void:
	if (self.get_global_rect().has_point(get_global_mouse_position())
		and ControllerSupport.event_is_action_pressed(event, "interact_grab")
	):
		_on_pressed()
		get_viewport().set_input_as_handled()


func _on_pressed() -> void:
	print("[WIRE_BUTTON][ON_PRESSED] Now holding wire ", wire_type)
	emit_signal("wire_changed", wire_type)
	AudioManager.play_sound("select")
