extends Node

enum WaveState { FLAT, WAVY }

const vc := preload("res://scripts/puzzles/troubleshooter/value_converter.gd").ValueConverter
const LIGHTS: Array[StandardMaterial3D] = [
	preload("res://assets/materials/red_light.tres"),
	preload("res://assets/materials/green_light.tres"),
	preload("res://assets/materials/blue_light.tres")
]
const FLOAT_EPSILON: float = 0.05
const BUTTON_STATES: int = 3

var inputs: Dictionary[String, MachineInput]
var outputs: Dictionary[String, MachineOutput]
var input_to_output: Dictionary[String, String]
var solutions: Dictionary[String, Variant]

@onready var _button: Button = %Inputs/Button
@onready var _dial: SpinBox = %Inputs/SpinBox
@onready var _slider: HSlider = %Inputs/HSlider
@onready var _wave: Sprite3D = %Outputs/Wave
@onready var _gauge: Node3D = %Outputs/Gauge
@onready var _color: MeshInstance3D = %Outputs/Color
@onready var _wave_solution: Sprite3D = %Solutions/Wave
@onready var _gauge_solution: Node3D = %Solutions/Gauge
@onready var _color_solution: MeshInstance3D = %Solutions/Color

var _solved: bool = false
var _button_state: int = 0

func _ready() -> void:
	inputs = {
		"button": MachineInput.new(
			_button,
			_button.pressed,
			func (_b: Button) -> float:
				_button_state = wrapi(_button_state + 1, 0, BUTTON_STATES)
				return _button_state,
			func (v: int) -> float: return vc.convert_discrete_to_intermediate(
				v,
				range(BUTTON_STATES)
			),
			func () -> int: return randi() % BUTTON_STATES
		),
		"dial": MachineInput.new(
			_dial,
			_dial.value_changed,
			func (n: Range) -> int: return int(n.value),
			func (v: float) -> float: return vc.convert_discrete_to_intermediate(
				floori(v),
				range(floori(_dial.min_value), floori(_dial.max_value) + 1)
			),
			func () -> int: return randi_range(floori(_dial.min_value), floori(_dial.max_value))
		),
		"slider": MachineInput.new(
			_slider,
			_slider.value_changed,
			func (n: Range) -> float: return n.value,
			func (v: float) -> float: return vc.convert_float_to_intermediate(
				v,
				_slider.min_value,
				_slider.max_value
			),
			func () -> float: return randf_range(_slider.min_value, _slider.max_value)
		),
	}

	outputs = {
		"wave": MachineOutput.new(
			_wave,
			_wave_solution,
			func (w: Sprite3D, v: Variant) -> void: w.frame = WaveState[v],
			func (i: float) -> Variant: return vc.convert_intermediate_to_discrete(
				i,
				WaveState.keys()
			),
			func (w: Sprite3D, s: Sprite3D) -> bool: return w.frame == s.frame
		),
		"gauge": MachineOutput.new(
			_gauge,
			_gauge_solution,
			func (g: Node3D, v: float) -> void: g.scale.x = v,
			func (i: float) -> float: return vc.convert_intermediate_to_float(
				i,
				0.1,
				1.0
			),
			func (g: Node3D, s: Node3D) -> bool: return abs(g.scale.x - s.scale.x) < FLOAT_EPSILON
		),
		"color": MachineOutput.new(
			_color,
			_color_solution,
			func (c: MeshInstance3D, v: StandardMaterial3D) -> void:
				c.mesh.surface_set_material(
					0,
					v
				),
			func (i: float) -> StandardMaterial3D: return vc.convert_intermediate_to_discrete(
				i,
				LIGHTS
			),
			func (c: MeshInstance3D, s: MeshInstance3D) -> bool: return (
				c.mesh.surface_get_material(0) == s.mesh.surface_get_material(0)
			)
		),
	}
	
	$ResetButton.pressed.connect(_generate_puzzle)
	_generate_puzzle()

func _process(_delta: float) -> void:
	_solved = _is_solved()
	
	$SolutionText.visible = _solved
	$ResetButton.disabled = not _solved

func _generate_puzzle() -> void:
	var input_keys: Array = inputs.keys()
	var output_keys: Array = outputs.keys()
	output_keys.shuffle()
	
	for i: int in mini(input_keys.size(), output_keys.size()):
		input_to_output[input_keys[i]] = output_keys[i]
	
	print(input_to_output)

	for i: String in input_to_output:
		var o: String = input_to_output[i]
		
		# Connect inputs and outputs
		inputs[i].signal_triggered.connect(func (..._args: Array) -> void:
			outputs[o].set_from_intermediate(inputs[i].get_as_intermediate())
			print(outputs[o].check_is_solved())
		)
		
		# Initialize output state
		outputs[o].set_from_intermediate(inputs[i].get_as_intermediate())
		outputs[o].set_solution_from_intermediate(inputs[i].get_random_as_intermediate())
		# Ensure outputs don't start solved
		while outputs[o].check_is_solved():
			outputs[o].set_solution_from_intermediate(inputs[i].get_random_as_intermediate())

func _is_solved() -> bool:
	for o: String in outputs:
		if not outputs[o].check_is_solved():
			return false
		
	return true

class MachineInput:
	var signal_triggered: Signal
	
	var _node: Node
	var _get_value: Callable
	var _convert_to_intermediate: Callable
	var _choose_random_value: Callable
	
	func _init(
		node: Node,
		trigger_signal: Signal,
		value_getter: Callable,
		convert_to_intermediate: Callable,
		choose_random_value: Callable
	) -> void:
		signal_triggered = trigger_signal
		_node = node
		_get_value = value_getter
		_convert_to_intermediate = convert_to_intermediate
		_choose_random_value = choose_random_value
	
	func get_raw() -> Variant:
		return _get_value.call(_node)
	
	func get_as_intermediate() -> float:
		return _convert_to_intermediate.call(_get_value.call(_node))
		
	func get_random_as_intermediate() -> float:
		return _convert_to_intermediate.call(_choose_random_value.call())


class MachineOutput:
	var _node: Node
	var _solution_node: Node
	var _set_value: Callable
	var _convert_from_intermediate: Callable
	var _check_solution: Callable
	
	func _init(
		node: Node,
		solution_node: Node,
		value_setter: Callable,
		convert_from_intermediate: Callable,
		solution_checker: Callable
	) -> void:
		_node = node
		_solution_node = solution_node
		_set_value = value_setter
		_convert_from_intermediate = convert_from_intermediate
		_check_solution = solution_checker
	
	func set_from_intermediate(intermediate: float) -> void:
		_set_value.call(_node, _convert_from_intermediate.call(intermediate))
		
	func set_solution_from_intermediate(intermediate: float) -> void:
		_set_value.call(_solution_node, _convert_from_intermediate.call(intermediate))
		
	func check_is_solved() -> bool:
		return _check_solution.call(_node, _solution_node)
