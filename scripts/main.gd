extends Node

signal main_menu_requested
signal restart_requested

@onready var _machine: Machine = $LyleFocusBox/FocusHandle/Machine
@onready var _machine_interface_linker: MachineInterfaceLinker = $LyleMachineandInterfaceLinker

func _ready() -> void:
	# TODO: Connect machine set up signal to machine interface linker intialize function
	_machine.machine_initialized.connect(_machine_interface_linker.initialize)
	pass

func _on_new_cousin_pressed() -> void:
	restart_requested.emit()

func _on_return_home_pressed() -> void:
	main_menu_requested.emit()
