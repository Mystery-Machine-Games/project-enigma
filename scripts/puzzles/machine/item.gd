class_name Item
extends Object

var _type: String
var _text: String
var _data: Variant


func _init(type: String, text: String, data: Variant) -> void:
	_type = type
	_text = text
	_data = data


func get_type() -> String:
	return _type


func get_text() -> String:
	return _text


func get_data() -> Variant:
	return _data
