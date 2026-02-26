class_name WireButtons
extends VBoxContainer

var _wire_buttons: Array[WireButton]


func _ready() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is WireButton:
			_wire_buttons.append(child)


func connect_signals(function: Callable) -> void:
	for button: WireButton in _wire_buttons:
		button.wire_changed.connect(function)


func hide_button(type: String) -> void:
	for button: WireButton in _wire_buttons:
		if button.wire_type == type:
			button.hide()
			break


func show_button(type: String) -> void:
	for button: WireButton in _wire_buttons:
		if button.wire_type == type:
			button.show()
			break
