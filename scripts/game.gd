extends Node

@onready var _interface: Interface = $Interface
@onready var _machine: Machine = $Machine


func _ready() -> void:
	var wire_buttons: WireButtons = _interface.get_wire_buttons()
	var wire_module: WireModule = _machine.get_wire_module()
	wire_buttons.connect_signals(wire_module.change_wire)
