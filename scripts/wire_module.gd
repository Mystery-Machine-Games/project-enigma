class_name WireModule
extends Node3D

enum Axis {X, Y, Z}

@export var start_port_positions: Array[Vector3]
@export var end_port_distance: float
@export var port_axis: Axis

const NUM_WIRES: int = 3

@onready var _difficulty: int = randi_range(1, 3)
@onready var _start_ports: Array[Node] = $StartPorts.get_children()
@onready var _end_ports: Array[Node] = $EndPorts.get_children()

var _wire_solution: Array[MachineWire]
var _current_solution: Array[MachineWire]
var _current_ports: Array[MachinePort]

signal wires_correct


func _ready() -> void:
	# Create random solution in form [[start_port, end_port], [start_port, end_port], [start_port, end_port]]
	# Pick random colors for start and end ports
	# Apply colors
	# Shuffle positions of start and end ports
	_start_ports.shuffle()
	_end_ports.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		var new_wire: MachineWire = MachineWire.new(start_port, end_port)
		_wire_solution.append(new_wire)
	print("[WIRE_MODULE][READY] Wire solution created: ", _wire_solution)
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		start_port.port_pressed.connect(_log_interaction)
		end_port.port_pressed.connect(_log_interaction)


func _log_interaction(port: MachinePort) -> void:
	if _current_ports.size() == 0 and _start_ports.find(port) != -1:
		_current_ports.append(port)
	elif _current_ports.size() == 1 and _end_ports.find(port) != -1:
		_current_ports.append(port)
	else:
		print("[WIRE_MODULE][LOG_INTERACTION] Failed to add port: incorrect sequence")
	if _current_ports.size() == 2:
		_add_wire()
	if _check_solution(): emit_signal("wires_correct")


func _add_wire() -> void:
	var new_wire: MachineWire = MachineWire.new(_current_ports[0], _current_ports[1])
	_current_solution.append(new_wire)
	_current_ports.clear()
	print("[WIRE_MODULE][LOG_INTERACTION] Added wire ", str(_current_solution.size()))
	pass


func _remove_wire(wire: MachineWire) -> void:
	var wire_index: int = _current_solution.find(wire)
	_current_solution.remove_at(wire_index)
	_current_ports.clear()
	print("[WIRE_MODULE][LOG_INTERACTION] Removed wire ", str(wire_index + 1))
	pass


# The order of wires in _wire_solution and _current_solution matters
func _check_solution() -> bool:
	for i: int in range(_wire_solution.size()):
		if _wire_solution[i] != _current_solution[i]:
			print("[WIRE_MODULE][CHECK_SOLUTION] Solution is incorrect")
			return false
	print("[WIRE_MODULE][CHECK_SOLUTION] Solution is correct")
	return true


func _generate_clues() -> void:
	pass
