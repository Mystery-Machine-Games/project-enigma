class_name MachineInterfaceLinker
extends Node

@onready var _interface: Interface = $"../Interface"
@onready var _machine: Machine = $"../LyleFocusBox/FocusHandle/Machine"


func initialize() -> void:
	var wire_buttons: WireButtons = _interface.get_wire_buttons()
	var wire_module: WireModule = _machine.get_wire_module()
	wire_buttons.connect_signals(wire_module.change_wire)
	wire_module.wire_added.connect(wire_buttons.add_wire)
	wire_module.wire_removed.connect(wire_buttons.remove_wire)
	_interface.visible = false;
	wire_buttons.visible = false;
