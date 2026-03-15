class_name PauseMenu
extends PanelContainer

signal resume_requested
signal options_requested
signal main_menu_requested

@onready var focus_entry: Control = %Resume


func _ready() -> void:
	focus_entry.grab_focus.call_deferred()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		resume_requested.emit()

func _on_resume_pressed() -> void:
	resume_requested.emit()

func _on_options_pressed() -> void:
	options_requested.emit()

func _on_return_to_main_pressed() -> void:
	main_menu_requested.emit()
