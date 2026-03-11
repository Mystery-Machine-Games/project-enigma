extends Node

@onready var _machine: Machine = $LyleFocusBox/FocusHandle/Machine
@onready var _machine_interface_linker: MachineInterfaceLinker = $LyleMachineandInterfaceLinker


func _ready() -> void:
	# TODO: Connect machine set up signal to machine interface linker intialize function
	_machine.machine_initialized.connect(_machine_interface_linker.initialize)
	pass
