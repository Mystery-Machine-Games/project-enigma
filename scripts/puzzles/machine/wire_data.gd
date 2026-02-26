class_name MachineWireData
extends Node3D

var _start_port: StaticBody3D
var _end_port: StaticBody3D
var _type: String


func _init(start_port: StaticBody3D, end_port: StaticBody3D, type: String) -> void:
	_start_port = start_port
	_end_port = end_port
	_type = type


func get_start_port() -> StaticBody3D:
	return _start_port


func get_end_port() -> StaticBody3D:
	return _end_port


func get_type() -> String:
	return _type


func ports_are_equal(wire: MachineWireData) -> bool:
	if _start_port == wire.get_start_port() and _end_port == wire.get_end_port():
		return true
	return false


func _to_string() -> String:
	var output: String = _start_port.name + " -> " + _end_port.name
	return output
