class_name Interface
extends Control

const WIRE_VIEW_INDEX: int = 1

@onready var _wire_buttons: WireButtons = $WireButtonsContainer

func _process(_delta: float) -> void:
	_wire_buttons.visible = $"../LyleFocusBox".focus_index == WIRE_VIEW_INDEX

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_clue"):
		_on_jigsaw_pressed()

func get_wire_buttons() -> WireButtons:
	return _wire_buttons

func _on_jigsaw_pressed() -> void:
	$Control.visible = !$Control.visible
