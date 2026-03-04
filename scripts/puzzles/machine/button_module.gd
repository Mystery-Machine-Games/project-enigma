class_name ButtonModule
extends Node3D

@export var button_positions: Array[Vector3]

enum Interaction {PRESS, HOLD}

const NUM_BUTTONS: int = 3
# Depending on whether the interaction is PRESS or HOLD, these numbers determine the # of presses or the time to hold, respectively
const POSSIBLE_INTERACTION_NUMS: Array[int] = [1, 2, 3, 4, 5]

@onready var _difficulty: int
@onready var _possible_button_colors: Array[Material]
@onready var _interaction: Interaction = Interaction.values().pick_random()
@onready var _buttons: Array[Node] = get_children()
@onready var _interaction_nums: Array[int] = POSSIBLE_INTERACTION_NUMS.duplicate()
var _interaction_history: Dictionary[Node, float]

signal buttons_correct
signal clueset_generated;


func initialize_puzzle() -> void:
	_pick_random_colors()
	_apply_colors()
	_pick_random_interaction_nums()
	_generate_solution()
	_set_random_positions()
	_generate_clues()
	_connect_signals()


func _pick_random_colors() -> void:
	var num_to_remove: int = _possible_button_colors.size() - NUM_BUTTONS
	for i: int in range(num_to_remove):
		var random_color_index: int = randi_range(0, _possible_button_colors.size() - 1)
		_possible_button_colors.remove_at(random_color_index)
	_possible_button_colors.shuffle()


func _pick_random_interaction_nums() -> void:
	for i: int in range(POSSIBLE_INTERACTION_NUMS.size() - NUM_BUTTONS):
		var random_num_index: int = randi_range(0, _interaction_nums.size() - 1)
		_interaction_nums.remove_at(random_num_index)
	_interaction_nums.shuffle()


func _generate_solution() -> void:
	var _sorted_interaction_nums: Array[int] = _interaction_nums.duplicate()
	_sorted_interaction_nums.sort()
	print("[BUTTON_MODULE][READY]\nSolution:\nInteraction: ", Interaction.keys()[_interaction],
	 "\nNumbers: ", _sorted_interaction_nums,
	 "\nDifficulty [1-3]: ", _difficulty, "\n")


func _apply_colors() -> void:
	for i: int in range(NUM_BUTTONS):
		var button: MachineButton = _buttons[i]
		var button_mesh: MeshInstance3D = button.find_child("ButtonMesh")
		button_mesh.material_override = _possible_button_colors[i]


func _connect_signals() -> void:
	for i: int in range(NUM_BUTTONS):
		var button: MachineButton = _buttons[i]
		button.button_pressed.connect(_log_interaction)
		

func _set_random_positions() -> void:
	_buttons.shuffle()
	for i: int in range(NUM_BUTTONS):
		var button: MachineButton = _buttons[i]
		button.position = button_positions[i]


func _log_interaction(button: Node, time_down: float) -> void:
	match _interaction:
		Interaction.PRESS:
			if _interaction_history.get(button):
				_interaction_history[button] = _interaction_history.get(button) + 1
			else:
				_interaction_history[button] = 1
		Interaction.HOLD:
			_interaction_history[button] = time_down
			
	print("[BUTTON_MODULE][LOG_INTERACTION] ", _interaction_history)
	if _check_solution(): emit_signal("buttons_correct")


func _check_solution() -> bool:
	var i: int = 0
	for interaction: Node in _interaction_history:
		var interaction_num: float = _interaction_history[interaction]
		if interaction != _buttons[i]:
			_interaction_history.clear()
			print("[BUTTON_MODULE][CHECK_SOLUTION] Button order incorrect, cleared")
			return false
		if round(interaction_num) != round(_interaction_nums[i]):
			match _interaction:
				Interaction.PRESS:
					if _interaction_history.size() > i + 1 or round(interaction_num) > round(_interaction_nums[i]):
						_interaction_history.clear()
						print("[BUTTON_MODULE][CHECK_SOLUTION] Button presses incorrect, cleared history")
				Interaction.HOLD:
					_interaction_history.clear()
					print("[BUTTON_MODULE][CHECK_SOLUTION] Button holds incorrect, cleared history")
			return false
		i += 1
	if _interaction_history.size() == NUM_BUTTONS:
		print("[BUTTON_MODULE][CHECK_SOLUTION] Buttons successfully solved")
		return true
	print("[BUTTON_MODULE][CHECK_SOLUTION] Solution not complete yet, but correct so far")
	return false


func _generate_clues() -> void:
	var clueset: Clueset = Clueset.new()
	
	# Add all items
	for i: int in range(_buttons.size()):
		var button: StaticBody3D = _buttons[i]
		var interaction_num: int = _interaction_nums[i]
		var machine_button: MachineButton = button
		var button_code: String = machine_button.code
		clueset.add_item("Button", button, [button_code], button.name, true)
		
		var order_text: String
		match i + 1:
			1: order_text = "1st"
			2: order_text = "2nd"
			3: order_text = "3rd"
		clueset.add_item("Order", i + 1, ["hashtag", str(i+1) + "centered"], order_text)
		
		var interaction_text: String
		var unit_text: String
		match _interaction:
			Interaction.PRESS: 
				interaction_text = "press"
				unit_text = "times"
			Interaction.HOLD: 
				interaction_text = "hold"
				unit_text = "seconds"
		var clue_text: String = interaction_text + " " + str(interaction_num) + " " + unit_text
		
		clueset.add_item("Interaction", interaction_num, [interaction_text, str(interaction_num), unit_text], clue_text)
		
	# Choose random assumption (no clues associated with it)
	var assumption_index: int = randi_range(0, _buttons.size() - 1)
	
	# Create intial positive associations (edges with positive weight)
	for i: int in range(_buttons.size()):
		if i == assumption_index: continue
		
		var button: StaticBody3D = _buttons[i]
		var interaction_num: int = _interaction_nums[i]
		
		var button_item: Item = clueset.find_item(button.name)
		
		var order_text: String
		match i + 1:
			1: order_text = "1st"
			2: order_text = "2nd"
			3: order_text = "3rd"
		var order_item: Item = clueset.find_item(order_text)
		
		var interaction_text: String
		var unit_text: String
		match _interaction:
			Interaction.PRESS: 
				interaction_text = "press"
				unit_text = "times"
			Interaction.HOLD: 
				interaction_text = "hold"
				unit_text = "seconds"
		var clue_text: String = interaction_text + " " + str(interaction_num) + " " + unit_text
		var interaction_vertex: Item = clueset.find_item(clue_text)
		
		clueset.add_clue(button_item, order_item, true)
		clueset.add_clue(order_item, interaction_vertex, true)
	#print("[BUTTON_MODULE][GENERATE CLUES]\nClueset (before replacements):\n", str(clueset))
	
	# Follow procedure to replace positive weight edges with negative weight edges
	if _difficulty > 0:
		clueset.assumption_replacement()
	if _difficulty > 1:
		clueset.assumption_replacement()
	
	print("[BUTTON_MODULE][GENERATE_CLUES]\nClueset:\n", str(clueset))
	clueset_generated.emit(clueset);


func set_difficulty(difficulty: int) -> void:
	_difficulty = difficulty


func set_colors(colors: Array[Material]) -> void:
	_possible_button_colors = colors.duplicate()
