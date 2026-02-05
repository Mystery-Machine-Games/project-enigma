extends Node

@export var button_positions: Array[Vector3]
@export var button_colors: Array[Material]

enum Interaction {PRESS, HOLD}

const NUM_BUTTONS: int = 3
# Depending on whether the interaction is PRESS or HOLD, these numbers determine the # of presses or the time to hold, respectively
const POSSIBLE_INTERACTION_NUMS: Array[int] = [1, 2, 3, 4, 5]

@onready var _possible_button_colors: Array[Material] = button_colors.duplicate()
@onready var _interaction: Interaction = Interaction.values().pick_random()
@onready var _buttons: Array[Node] = get_children()
@onready var _interaction_nums: Array[int] = POSSIBLE_INTERACTION_NUMS.duplicate()
var _interaction_history: Dictionary[Node, float]

signal buttons_correct


func _ready() -> void:
	_buttons.shuffle()
	for i in range(POSSIBLE_INTERACTION_NUMS.size() - NUM_BUTTONS):
		var random_num_index: int = randi_range(0, _interaction_nums.size() - 1)
		var random_color_index: int = randi_range(0, _possible_button_colors.size() - 1)
		_interaction_nums.remove_at(random_num_index)
		_possible_button_colors.remove_at(random_color_index)
	_interaction_nums.shuffle()
	_possible_button_colors.shuffle()
	print("[BUTTON_MODULE][SOLUTION] Interaction: ", Interaction.keys()[_interaction], " Order: ", _buttons, " Numbers: ", _interaction_nums)
	
	for i in range(_buttons.size()):
		var button: StaticBody3D = _buttons[i]
		button.button_pressed.connect(_log_interaction)
		button.position = button_positions[i]
		button.find_child("Button").material_override = _possible_button_colors[i]


func _log_interaction(button: Node, time_down: float) -> void:
	match _interaction:
		Interaction.PRESS:
			if _interaction_history.get(button):
				_interaction_history[button] = _interaction_history.get(button) + 1
			else:
				_interaction_history[button] = 1
		Interaction.HOLD:
			_interaction_history[button] = time_down
			
	print("[BUTTON_MODULE][LOG INTERACTION] ", _interaction_history)
	if _check_solution(): emit_signal("buttons_correct")


func _check_solution() -> bool:
	var i: int = 0
	for interaction in _interaction_history:
		var interaction_num: float = _interaction_history[interaction]
		if interaction != _buttons[i]:
			_interaction_history.clear()
			print("[BUTTON_MODULE][CHECK SOLUTION] Button order incorrect, cleared")
			return false
		if round(interaction_num) != round(_interaction_nums[i]):
			match _interaction:
				Interaction.PRESS:
					if _interaction_history.size() > i + 1 or round(interaction_num) > round(_interaction_nums[i]):
						_interaction_history.clear()
						print("[BUTTON_MODULE][CHECK SOLUTION] Button presses incorrect, cleared history")
				Interaction.HOLD:
					_interaction_history.clear()
					print("[BUTTON_MODULE][CHECK SOLUTION] Button holds incorrect, cleared history")
			return false
		i += 1
	if _interaction_history.size() == NUM_BUTTONS:
		print("[BUTTON_MODULE][CHECK SOLUTION] Buttons successfully solved")
		return true
	print("[BUTTON_MODULE][CHECK SOLUTION] Solution not complete yet, but correct so far")
	return false


func _generate_clues() -> Array[String]:
	return []
