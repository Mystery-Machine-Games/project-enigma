class_name WireButtons
extends VBoxContainer

var _wire_buttons: Array[WireButton]
var _placed_wire_types: Array[String]

@onready var _held_wire: TextureRect = $HeldWire


func _ready() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is WireButton:
			_wire_buttons.append(child)


func connect_signals(function: Callable) -> void:
	for button: WireButton in _wire_buttons:
		button.wire_changed.connect(function)
		button.wire_changed.connect(_update_ui)


func _update_ui(type: String) -> void:
	_disable_button(type)
	_enable_buttons(type)
	_update_held_wire(type)


func _disable_button(type: String) -> void:
	for button: WireButton in _wire_buttons:
		if button.wire_type == type:
			button.modulate = Color(0.5, 0.5, 0.5, 1.0)
			button.disabled = true
			break


func _enable_buttons(excluded_type: String) -> void:
	for button: WireButton in _wire_buttons:
		var curr_type: String = button.wire_type
		if curr_type != excluded_type and curr_type not in _placed_wire_types:
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)
			button.disabled = false


func _update_held_wire(type: String) -> void:
	_held_wire.texture = load(TypeSpriteDictionary.type_to_sprite(type).get_path())


func _enable_button(type: String) -> void:
	for button: WireButton in _wire_buttons:
		if button.wire_type == type:
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)
			button.disabled = false
			break


func add_wire(type: String) -> void:
	_update_held_wire("false")
	_placed_wire_types.append(type)


func remove_wire(type: String) -> void:
	var wire_type_index: int = _placed_wire_types.find(type)
	_placed_wire_types.remove_at(wire_type_index)
	_update_ui("false")

func get_available_wires() -> Array:
	return _wire_buttons.filter(func (b: WireButton) -> bool: return not b.disabled)
