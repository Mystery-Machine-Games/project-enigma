class_name MainMenu
extends Control

signal game_start_requested
signal options_menu_requested
@onready var _credits: PanelContainer = %CreditsPanel

func _input(event: InputEvent) -> void:
	if (_credits.visible
		and (event.is_action_pressed("ui_cancel")
			or (event is InputEventMouseButton
				and _has_clicked_outside(_credits, event as InputEventMouseButton)
		))):
		_credits.hide()
		get_viewport().set_input_as_handled()

func _on_play_pressed() -> void:
	game_start_requested.emit()

func _on_options_pressed() -> void:
	options_menu_requested.emit()

func _on_credits_pressed() -> void:
	_credits.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _has_clicked_outside(control: Control, event: InputEventMouseButton) -> bool:
	return (event is InputEventMouseButton
		and event.pressed 
		and not control.get_rect().has_point(event.position)
	)
