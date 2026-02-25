extends Node

@onready var _interface: Control = $"../Interface"
@onready var _machine: Node3D = $"../LyleFocusBox/FocusHandle/Machine"
# connect interface.wire_buttons.wire_changed to _machine.wire_module.change_wire()
func _ready() -> void:
	var wire_buttons: WireButtons = _interface.get_wire_buttons()
	var wire_module: WireModule = _machine.get_wire_module()
	wire_buttons.wire_changed.connect(wire_module.change_wire)
	$"../Interface".visible = false;
	$"../Interface".get_wire_buttons().visible = false;
