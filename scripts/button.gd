class_name MachineButton
extends Node

var _mouse_over: bool = false
var _mouse_down: bool = false
var _time_down: float = 0

enum Shape {CIRCLE, SQUARE, TRIANGLE}

@export var button_shape: Shape

signal button_pressed


func _process(delta: float) -> void:
	if _mouse_down:
		_time_down += delta
	elif _time_down > 0:
		print("The ", Shape.keys()[button_shape], " button was held down for ", _time_down, " seconds")
		emit_signal("button_pressed", self, _time_down)
		_time_down = 0


func _on_mouse_entered() -> void:
	_mouse_over = true


func _on_mouse_exited() -> void:
	_mouse_over = false
	if _mouse_down:
		#$AnimationPlayer.play("button_animations/button_release")
		_mouse_down = false


func _input(event: InputEvent) -> void:
	if _mouse_over and event.is_action_pressed("interact"):
		#$AnimationPlayer.play("button_animations/button_press")
		_mouse_down = true
	if _mouse_over and event.is_action_released("interact"):
		#$AnimationPlayer.play("button_animations/button_release")
		_mouse_down = false
