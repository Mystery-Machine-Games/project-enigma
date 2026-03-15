class_name WireModule
extends Node3D

enum Axis {X, Y, Z}

@export var wire_scene: PackedScene
@export var start_port_positions: Array[Vector3]
@export var end_port_distance: float
@export var port_axis: Axis

const NUM_WIRES: int = 3
const POSSIBLE_WIRE_TYPES: Array[String] = ["I", "II", "III"]

@onready var _start_ports: Array[Node] = $StartPorts.get_children()
@onready var _end_ports: Array[Node] = $EndPorts.get_children()
@onready var _possible_port_colors: Array[Material]
@onready var _possible_wire_colors: Array[Material]
@onready var _possible_wire_types: Array[String] = POSSIBLE_WIRE_TYPES.duplicate()

var _difficulty: int
var _wire_solution: Array[MachineWireData]
var _current_solution: Array[MachineWireData]
var _current_ports: Array[MachinePort]
var _current_wire_type: String = ""

signal wire_added
signal wire_removed
signal wires_correct
signal clueset_generated


func initialize_puzzle() -> void:
	_pick_random_colors()
	_apply_colors()
	_generate_solution()
	_set_random_positions()
	_generate_clues()
	_connect_signals()


func _pick_random_colors() -> void:
	var num_to_remove: int = _possible_port_colors.size() - NUM_WIRES
	for i: int in range(num_to_remove):
		var random_port_color_index: int = randi_range(0, _possible_port_colors.size() - 1)
		var random_wire_color_index: int = randi_range(0, _possible_wire_colors.size() - 1)
		_possible_port_colors.remove_at(random_port_color_index)
		_possible_wire_colors.remove_at(random_wire_color_index)
	_possible_wire_colors.shuffle()


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
		start_port.set_sprite_color()
		end_port.set_sprite_color()


func _generate_solution() -> void:
	_start_ports.shuffle()
	_end_ports.shuffle()
	for i: int in range(NUM_WIRES):
		var start_port: MachinePort = _start_ports[i]
		var end_port: MachinePort = _end_ports[i]
		var wire_type: String = _possible_wire_types[i]
		var new_wire: MachineWireData = MachineWireData.new(start_port, end_port, wire_type)
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
		start_port.port_hovered.connect(_log_interaction)
		end_port.port_hovered.connect(_log_interaction)
		start_port.port_pressed.connect(_log_interaction)
		end_port.port_pressed.connect(_log_interaction)


func _log_interaction(port: MachinePort, pressed: bool) -> void:
	if _current_wire_type == "": 
		port.set_interactable(false)
		return
	elif port.is_filled(): 
		port.set_interactable(false)
		return
	elif !_is_next_port(port): 
		port.set_interactable(false)
		return
	else:
		port.set_interactable(true)
	
	if pressed:
		_current_ports.append(port)
	else: print("[WIRE_MODULE][LOG_INTERACTION] Failed to add port: Incorrect sequence")

	if _current_ports.size() == 2:
		_add_wire()
		if _check_solution(): emit_signal("wires_correct")


func _is_next_port(port: MachinePort) -> bool:
	if _current_ports.size() == 0 and _start_ports.find(port) != -1:
		return true
	elif _current_ports.size() == 1 and _end_ports.find(port) != -1:
		return true
	else: return false


func _add_wire() -> void:
	if _current_wire_type == "": return # Can only add wire if holding one

	var start_port: MachinePort = _current_ports[0]
	var end_port: MachinePort = _current_ports[1]
	start_port.set_filled(true)
	end_port.set_filled(true)
	var wire_data: MachineWireData = MachineWireData.new(start_port, end_port, _current_wire_type)
	var wire_instance: Node3D = wire_scene.instantiate()

	$Wires.add_child(wire_instance)
	wire_instance.position = start_port.position
	var wire: MachineWire = wire_instance
	wire.set_data(wire_data)
	wire.set_type_sprite()
	wire.wire_clicked.connect(_remove_wire)
	_current_solution.append(wire.get_data())
	_current_ports.clear()
	print("[WIRE_MODULE][LOG_INTERACTION] Added wire ", _current_wire_type, ": ", wire.get_data())
	_set_wire_pose(wire)

	# Apply random color to wire
	var wire_color_index: int
	match _current_wire_type:
		"I": wire_color_index = 0
		"II": wire_color_index = 1
		"III": wire_color_index = 2
	wire.set_color(_possible_wire_colors[wire_color_index])
	
	emit_signal("wire_added", wire.get_data().get_type())
	_current_wire_type = ""


func _set_wire_pose(wire: MachineWire) -> void:
	var wire_data: MachineWireData = wire.get_data()
	var start_port: MachinePort = wire_data.get_start_port()
	var end_port: MachinePort = wire_data.get_end_port()
	var anim_player: AnimationPlayer = wire.get_anim_player()
	var start_port_index: int = _start_ports.find(start_port)
	var end_port_index: int = _end_ports.find(end_port)
	
	if end_port_index - start_port_index == 1:
		anim_player.play("right")
	elif start_port_index - end_port_index == 1:
		anim_player.play("left")
	elif end_port_index - start_port_index == 2:
		anim_player.play("far_right")
	elif start_port_index - end_port_index == 2:
		anim_player.play("far_left")


func _remove_wire(wire_type: String) -> void:
	for child: Node3D in $Wires.get_children():
		var wire: MachineWire = child
		if wire.get_data().get_type() == wire_type:
			wire.queue_free()
	for i: int in range(_current_solution.size()):
		var wire_data: MachineWireData = _current_solution[i]
		var start_port: MachinePort = wire_data.get_start_port()
		var end_port: MachinePort = wire_data.get_end_port()
		start_port.set_filled(false)
		end_port.set_filled(false)
		if wire_data.get_type() == wire_type:
			_current_solution.remove_at(i)
			break
	print("[WIRE_MODULE][LOG_INTERACTION] Removed wire ", wire_type)
	_current_ports.clear()
	emit_signal("wire_removed", wire_type)


func _check_solution() -> bool:
	if _current_solution.size() == NUM_WIRES:
		for i: int in range(_wire_solution.size()):
			var solution_wire: MachineWireData = _wire_solution[i]
			var current_wire: MachineWireData = _current_solution[i]
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
		var wire: MachineWireData = _wire_solution[i]
		var start_port: MachinePort = wire.get_start_port()
		var end_port: MachinePort = wire.get_end_port()
		var wire_type: String = wire.get_type()
		clueset.add_item("Wire", wire, [wire_type], "Wire " + wire.get_type(), true)
		clueset.add_item("Start", start_port, [start_port.code], "starts at " + start_port.code)
		clueset.add_item("End", end_port, [end_port.code], "ends at " + end_port.code)
	
	# Choose random assumption (no clues associated with it)
	var assumption_index: int = randi_range(0, NUM_WIRES - 1)
	
	# Create intial positive associations (edges with positive weight)
	for i: int in range(NUM_WIRES):
		if i == assumption_index: continue
		
		var wire: MachineWireData = _wire_solution[i]
		var start_port: MachinePort = wire.get_start_port()
		var end_port: MachinePort = wire.get_end_port()
		
		var wire_item: Item = clueset.find_item("Wire " + wire.get_type())
		var start_port_item: Item = clueset.find_item("starts at " + start_port.code)
		var end_port_item: Item = clueset.find_item("ends at " + end_port.code)
		
		clueset.add_clue(wire_item, start_port_item, true)
		clueset.add_clue(start_port_item, end_port_item, true)
	
	# Follow procedure to replace positive weight edges with negative weight edges
	if _difficulty > 0:
		clueset.assumption_replacement()
	if _difficulty > 1:
		clueset.assumption_replacement()
	
	clueset.set_header(["I", "II", "III"])
	print("\n[WIRE_MODULE][GENERATE_CLUES]\nClueset:\n", str(clueset))
	clueset_generated.emit(clueset)


func change_wire(new_wire: String) -> void:
	_current_ports.clear()
	_current_wire_type = new_wire
	print("[WIRE_MODULE][CHANGE_WIRE] Changed wire to wire ", new_wire)


func set_difficulty(difficulty: int) -> void:
	_difficulty = difficulty


func set_colors(port_colors: Array[Material], wire_colors: Array[Material]) -> void:
	_possible_port_colors = port_colors.duplicate()
	_possible_wire_colors = wire_colors.duplicate()
