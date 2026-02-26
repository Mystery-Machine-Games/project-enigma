class_name Item
extends Object

var _codes: Array[String]
var _head: bool # Whether this item is the "head" of a category or not
var _category: String
var _text: String
var _data: Variant


func _init(category: String, data: Variant, codes: Array[String], text: String, head: bool) -> void:
	_codes = codes
	_text = text
	_data = data
	_head = head
	_category = category


func get_codes() -> Array[String]:
	return _codes


func get_text() -> String:
	return _text


func get_text_with_codes() -> String:
	var output: String = _text + "(codes: "
	for code: String in _codes:
		output += code
	output += ")"
	return output


func get_data() -> Variant:
	return _data


func get_category() -> String:
	return _category


func is_head() -> bool:
	return _head
