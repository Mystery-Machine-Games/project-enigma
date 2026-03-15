class_name Interface
extends Control

const WIRE_VIEW_INDEX: int = 1

@onready var _wire_buttons: WireButtons = $WireButtonsContainer

func _ready() -> void:
	($"../LyleFocusBox" as FocusItem).focus_index_changed.connect(_on_focus_index_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_clue"):
		_on_jigsaw_pressed()

func _on_focus_index_changed(focus_index: int) -> void:
	_wire_buttons.visible = focus_index == WIRE_VIEW_INDEX
	if _wire_buttons.visible:
		var first_button: BaseButton = _wire_buttons.get_available_wires().get(0)
		if first_button:
			first_button.grab_focus.call_deferred()

func get_wire_buttons() -> WireButtons:
	return _wire_buttons

func _on_jigsaw_pressed() -> void:
	$CluesContainer.visible = !$CluesContainer.visible
