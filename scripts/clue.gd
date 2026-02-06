class_name Clue
extends Object

var _item1: Item
var _item2: Item
var _positive: bool


func _init(item1: Item, item2: Item, positive: bool) -> void:
	_item1 = item1
	_item2 = item2
	_positive = positive


func get_items() -> Array[Item]:
	return [_item1, _item2]


func set_vertices(item1: Item, item2: Item) -> void:
	_item1 = item1
	_item2 = item2


func is_positive() -> bool:
	return _positive


func set_positive(positive: bool) -> void:
	_positive = positive
