class_name WireModule
extends Node3D

enum Axis {X, Y, Z}

@export var start_port_positions: Array[Vector3]
@export var end_port_distance: float
@export var port_axis: Axis
@export var port_colors: Array[Material]

const NUM_WIRES: int = 3
const POSSIBLE_WIRE_TYPES: Array[String] = ["A", "B", "C", "D", "E"]

@onready var _difficulty: int = randi_range(1, 3)
@onready var _start_ports: Array[Node] = $StartPorts.get_children()
@onready var _end_ports: Array[Node] = $EndPorts.get_children()
@onready var _possible_port_colors: Array[Material] = port_colors.duplicate()
@onready var _possible_wire_types: Array[String] = POSSIBLE_WIRE_TYPES.duplicate()

var _wire_solution: Array[MachineWire]
var _current_solution: Array[MachineWire]
var _current_ports: Array[MachinePort]

signal wires_correct


func _ready() -> void:
	# Create random solution in form [[start_port, end_port], [start_port, end_port], [start_port, end_port]]
	# Pick random colors for start and end ports
	for i: int in range(port_colors.size() - NUM_WIRES):
		var random_color_index: int = randi_range(0, _possible_port_colors.size() - 1)
		var random_type_index: int = randi_range(0, _possible_wire_types.size() - 1)
		_possible_port_colors.remove_at(random_color_index)
		_possible_wire_types.remove_at(random_type_index)
		
	# Apply colors (applying before shuffling the port arrays so that their shapes match up to colors)
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
		
	# Create solution
	_start_ports.shuffle()
	_end_ports.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		var wire_type: String = _possible_wire_types[i]
		var new_wire: MachineWire = MachineWire.new(start_port, end_port, wire_type)
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
	
	# Connect signals
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
		
		var order_text: String
		match i + 1:
			1: order_text = "1st"
			2: order_text = "2nd"
			3: order_text = "3rd"
		clueset.add_item(i + 1, "Order", order_text)
		
		# TODO Add items to clueset for start ports and end ports
		
	# Choose random assumption (no clues associated with it)
	#var assumption_index: int = randi_range(0, _buttons.size() - 1)
	
	# Create intial positive associations (edges with positive weight)
	#for i: int in range(_buttons.size()):
		#if i == assumption_index: continue
		#
		#var button: StaticBody3D = _buttons[i]
		#var interaction_num: int = _interaction_nums[i]
		#
		#var button_item: Item = clueset.find_item(button.name)
		#
		#var order_text: String
		#match i + 1:
			#1: order_text = "1st"
			#2: order_text = "2nd"
			#3: order_text = "3rd"
		#var order_item: Item = clueset.find_item(order_text)
		#
		#var interaction_text: String
		#match _interaction:
			#Interaction.PRESS: interaction_text = "press " + str(interaction_num) + " times"
			#Interaction.HOLD: interaction_text = "hold for " + str(interaction_num) + " seconds"
		#var interaction_vertex: Item = clueset.find_item(interaction_text)
		#
		#clueset.add_clue(button_item, order_item, true)
		#clueset.add_clue(order_item, interaction_vertex, true)
	##print("[BUTTON_MODULE][GENERATE CLUES]\nClueset (before replacements):\n", str(clueset))
	#
	## Follow procedure to replace positive weight edges with negative weight edges
	#if _difficulty > 1:
		#clueset.assumption_replacement()
	#if _difficulty > 2:
		#clueset.assumption_replacement()
	#
	#print("[WIRE_MODULE][GENERATE_CLUES]\nClueset:\n", str(clueset))
