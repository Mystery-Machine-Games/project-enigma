class_name PauseMenu
extends PanelContainer

signal options_requested
signal main_menu_requested

func _on_options_pressed() -> void:
	options_requested.emit()

func _on_return_to_main_pressed() -> void:
	main_menu_requested.emit()
