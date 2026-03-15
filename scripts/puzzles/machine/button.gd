class_name MachineButton
extends StaticBody3D

signal button_held(hold_duration: float)

@export var code: String

@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _outline_mesh: MeshInstance3D = $OutlineMesh

var _mouse_over: bool = false
var _mouse_down: bool = false
var _time_down: float = 0

signal button_pressed


func _ready() -> void:
	_outline_mesh.visible = false


func _process(delta: float) -> void:
	if _mouse_down:
		_time_down += delta
		button_held.emit(_time_down)
	elif _time_down > 0:
		print("[BUTTON][PROCESS] The ", name, " was held down for ", _time_down, " seconds")
		emit_signal("button_pressed", self, _time_down)
		_time_down = 0


func _on_mouse_entered() -> void:
	_mouse_over = true
	_outline_mesh.visible = true


func _on_mouse_exited() -> void:
	_mouse_over = false
	if _mouse_down:
		_anim_player.play_backwards("button_press")
		_mouse_down = false
	_outline_mesh.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _mouse_over and ControllerSupport.event_is_action_pressed(event, "interact_grab"):
		print("press")
		_anim_player.play("button_press")
		_mouse_down = true
		_outline_mesh.visible = false
	elif _mouse_over and event.is_action_released("interact_grab"):
		print("release")
		_anim_player.play_backwards("button_press")
		_mouse_down = false
		_outline_mesh.visible = true
