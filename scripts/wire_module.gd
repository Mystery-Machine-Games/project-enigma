class_name WireModule
extends Node3D

enum Axis {X, Y, Z}

@export var start_port_positions: Array[Vector3]
@export var end_port_distance: float
@export var port_axis: Axis
@export var port_colors: Array[Material]

const NUM_WIRES: int = 3

@onready var _difficulty: int = randi_range(1, 3)
@onready var _start_ports: Array[Node] = $StartPorts.get_children()
@onready var _end_ports: Array[Node] = $EndPorts.get_children()
@onready var _possible_port_colors: Array[Material] = port_colors.duplicate()

var _wire_solution: Array[MachineWire]
var _current_solution: Array[MachineWire]
var _current_ports: Array[MachinePort]

signal wires_correct


func _ready() -> void:
	# Create random solution in form [[start_port, end_port], [start_port, end_port], [start_port, end_port]]
	# Pick random colors for start and end ports
	for i: int in range(port_colors.size() - NUM_WIRES):
		var random_color_index: int = randi_range(0, _possible_port_colors.size() - 1)
		_possible_port_colors.remove_at(random_color_index)
	# Apply colors (applying before shuffling the port arrays so that their shapes match up to colors)
	_possible_port_colors.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		var start_port_mesh: MeshInstance3D = start_port.find_child("PortMesh")
		var end_port_mesh: MeshInstance3D = end_port.find_child("PortMesh")
		var port_color: Material = _possible_port_colors[i]
		start_port_mesh.material_override = port_color
		end_port_mesh.material_override = port_color
	# Create solution
	_start_ports.shuffle()
	_end_ports.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		var new_wire: MachineWire = MachineWire.new(start_port, end_port)
		_wire_solution.append(new_wire)
	_wire_solution.shuffle()
	# Randomize positions
	_start_ports.shuffle()
	_end_ports.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		start_port.position = start_port_positions[i]
		match(port_axis):
			Axis.X:
				end_port.position = start_port_positions[i] + Vector3(end_port_distance, 0, 0)
			Axis.Y:
				end_port.position = start_port_positions[i] + Vector3(0, end_port_distance, 0)
			Axis.Z:
				end_port.position = start_port_positions[i] + Vector3(0, 0, end_port_distance)
	print("[WIRE_MODULE][READY]\nWire solution:\n", _wire_solution)
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
	print("[WIRE_MODULE][LOG_INTERACTION] Added wire ", str(_current_solution.size()), ": ", new_wire)
	pass


func _remove_wire(wire: MachineWire) -> void:
	var wire_index: int = _current_solution.find(wire)
	print("[WIRE_MODULE][LOG_INTERACTION] Removed wire ", str(wire_index + 1), ": ", _current_solution[wire_index])
	_current_solution.remove_at(wire_index)
	_current_ports.clear()
	pass


# The order of wires in _wire_solution and _current_solution matters
func _check_solution() -> bool:
	if _current_solution.size() == NUM_WIRES:
		for i: int in range(_wire_solution.size()):
			var solution_wire: MachineWire = _wire_solution[i]
			var current_wire: MachineWire = _current_solution[i]
			if !current_wire.ports_are_equal(solution_wire):
				print("[WIRE_MODULE][CHECK_SOLUTION] Solution is incorrect")
				return false
	else:
		print("[WIRE_MODULE][CHECK_SOLUTION] Solution is incomplete")
		return false
	print("[WIRE_MODULE][CHECK_SOLUTION] Solution is correct")
	return true


func _generate_clues() -> void:
	pass
