class_name Vertex
extends Object

var _name: String
var _data: Variant


func _init(name: String, data: Variant) -> void:
	_name = name
	_data = data


func get_name() -> String:
	return _name


func get_data() -> Variant:
	return _data
