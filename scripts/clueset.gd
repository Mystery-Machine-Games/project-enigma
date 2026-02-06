class_name Clueset
extends Object

var _items: Array[Item]
var _floating_items: Array[Item] # Vertices unconnected to any other vertices
var _clues: Array[Clue]


func add_item(data: Variant, type: String, text: String = "") -> Item:
	var new_item: Item = Item.new(type, text, data)
	_items.append(new_item)
	_floating_items.append(new_item)
	return new_item


func remove_item() -> void:
	pass # TODO


func add_edge(item1: Item, item2: Item, positive: bool = true) -> Clue:
	var new_clue: Clue = Clue.new(item1, item2, positive)
	_clues.append(new_clue)
	var item1_index: int = _floating_items.find(item1)
	var item2_index: int = _floating_items.find(item2)
	if item1_index != -1: _floating_items.remove_at(item1_index)
	if item2_index != -1: _floating_items.remove_at(item2_index)
	return new_clue


func remove_edge() -> void:
	pass # TODO


func find_item(text: String) -> Item:
	for item: Item in _items:
		if item.get_text() == text:
			return item
	return null


func pick_random_clue() -> Clue:
	return _clues.pick_random()


func get_floating_items() -> Array[Item]:
	return _floating_items


func _to_string() -> String:
	var output: String = ""
	for clue: Clue in _clues:
		var items: Array[Item] = clue.get_items()
		output += items[0].get_text() + " --> " + items[1].get_text() + "\n"
	return output


func free() -> void:
	for edge: Clue in _clues:
		edge.free()
	for item: Item in _items:
		item.free()
