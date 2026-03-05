class_name OptionsMenu
extends PanelContainer

signal options_close_requested

func _on_return_pressed() -> void:
	options_close_requested.emit()
