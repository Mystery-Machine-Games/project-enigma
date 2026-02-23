class_name WireModule
extends Node3D

enum Axis {X, Y, Z}

@export var start_port_positions: Array[Vector3]
@export var end_port_distance: float
@export var port_axis: Axis
@export var port_colors: Array[Material]

const NUM_WIRES: int = 3
const POSSIBLE_WIRE_TYPES: Array[String] = ["A", "B", "C"]

@onready var _difficulty: int = randi_range(1, 3)
@onready var _start_ports: Array[Node] = $StartPorts.get_children()
@onready var _end_ports: Array[Node] = $EndPorts.get_children()
@onready var _possible_port_colors: Array[Material] = port_colors.duplicate()
@onready var _possible_wire_types: Array[String] = POSSIBLE_WIRE_TYPES.duplicate()

var _wire_solution: Array[MachineWire]
var _current_solution: Array[MachineWire]
var _current_ports: Array[MachinePort]
var _current_wire: String

signal wires_correct


func _ready() -> void:
	_pick_random_colors()
	_apply_colors()
	_generate_solution()
	_set_random_positions()
	_generate_clues()
	_connect_signals()


func _pick_random_colors() -> void:
	for i: int in range(port_colors.size() - NUM_WIRES):
		var random_color_index: int = randi_range(0, _possible_port_colors.size() - 1)
		_possible_port_colors.remove_at(random_color_index)


# Note: Must be applied before shuffling the port arrays so that their shapes match up to colors
func _apply_colors() -> void:
	_possible_port_colors.shuffle()
	_possible_wire_types.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		var start_port_mesh: MeshInstance3D = start_port.find_child("PortMesh")
		var end_port_mesh: MeshInstance3D = end_port.find_child("PortMesh")
		var port_color: Material = _possible_port_colors[i]
		start_port_mesh.material_override = port_color
		end_port_mesh.material_override = port_color


func _generate_solution() -> void:
	_start_ports.shuffle()
	_end_ports.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		var wire_type: String = _possible_wire_types[i]
		var new_wire: MachineWire = MachineWire.new(start_port, end_port, wire_type)
		_wire_solution.append(new_wire)
	_wire_solution.shuffle()
	print("[WIRE_MODULE][READY]\nWire solution:\n", _wire_solution)


func _set_random_positions() -> void:
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


func _connect_signals() -> void:
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
	var start_port: MachinePort = _current_ports[0]
	var end_port: MachinePort = _current_ports[1]
	var wire_index: int = _current_solution.size()
	var wire_type: String = _possible_wire_types[wire_index]
	var new_wire: MachineWire = MachineWire.new(start_port, end_port, wire_type)
	_current_solution.append(new_wire)
	_current_ports.clear()
	print("[WIRE_MODULE][LOG_INTERACTION] Added wire ", wire_index, ": ", new_wire)
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
	var clueset: Clueset = Clueset.new()
	
	# Add all items
	for i: int in range(NUM_WIRES):
		var wire: MachineWire = _wire_solution[i]
		clueset.add_item(wire, "Head", "Wire " + wire.get_type())
		clueset.add_item(wire.get_start_port(), "Start", "starts at " + wire.get_start_port().name)
		clueset.add_item(wire.get_end_port(), "End", "ends at " + wire.get_end_port().name)
	
	# Choose random assumption (no clues associated with it)
	var assumption_index: int = randi_range(0, NUM_WIRES - 1)
	
	# Create intial positive associations (edges with positive weight)
	for i: int in range(NUM_WIRES):
		if i == assumption_index: continue
		
		var wire: MachineWire = _wire_solution[i]
		
		var wire_item: Item = clueset.find_item("Wire " + wire.get_type())
		var start_port_item: Item = clueset.find_item("starts at " + wire.get_start_port().name)
		var end_port_item: Item = clueset.find_item("ends at " + wire.get_end_port().name)
		
		clueset.add_clue(wire_item, start_port_item, true)
		clueset.add_clue(start_port_item, end_port_item, true)
	
	print("[WIRE_MODULE][GENERATE_CLUES]\nClueset (before replacements):\n", str(clueset))
	
	# Follow procedure to replace positive weight edges with negative weight edges
	if _difficulty > 1:
		clueset.assumption_replacement()
	if _difficulty > 2:
		clueset.assumption_replacement()
	
	print("[WIRE_MODULE][GENERATE_CLUES]\nClueset:\n", str(clueset))


func change_wire(new_wire: String) -> void:
	_current_wire = new_wire
	print("[WIRE_MODULE][CHANGE_WIRE] Changed wire to wire ", new_wire)
	# +anything else that needs to be done here
