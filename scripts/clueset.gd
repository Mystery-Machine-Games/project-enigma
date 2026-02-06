class_name Clueset
extends Object

var _items: Array[Item]
var _floating_items: Array[Item] # Vertices unconnected to any other vertices
var _positive_clues: Array[Clue]
var _negative_clues: Array[Clue]


func add_item(data: Variant, type: String, text: String = "") -> Item:
	var new_item: Item = Item.new(type, text, data)
	_items.append(new_item)
	_floating_items.append(new_item)
	return new_item


func remove_item() -> void:
	pass # TODO


func add_clue(item1: Item, item2: Item, positive: bool = true) -> Clue:
	var new_clue: Clue = Clue.new(item1, item2, positive)
	if positive: _positive_clues.append(new_clue)
	else: _negative_clues.append(new_clue)
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


func pick_random_floating_item(type: String) -> Item:
	_floating_items.shuffle()
	for item: Item in _floating_items:
		if item.get_type() == type:
			return item
	return null


func pick_random_clue(positive: bool) -> Clue:
	if positive: return _positive_clues.pick_random()
	else: return _negative_clues.pick_random()


func replace_random_positive_clue() -> Clue:
	# Choose a random positive clue
	var clue: Clue = pick_random_clue(true)
	# Pick random floating item according to type of item2 of clue
	var item_type: String = clue.get_items()[1].get_type()
	var assumption_item: Item = pick_random_floating_item(item_type)
	# Set new items of that clue to existing item1 and new item2 from random floating item (assumption)
	clue.set_items(clue.get_items()[0], assumption_item)
	# Set new positive to false
	clue.set_positive(false)
	# return new clue
	return clue


func get_floating_items() -> Array[Item]:
	return _floating_items


func _to_string() -> String:
	var output: String = ""
	for clue: Clue in _positive_clues:
		var items: Array[Item] = clue.get_items()
		if clue.is_positive(): output += items[0].get_text() + " --> " + items[1].get_text() + "\n"
		else: output += items[0].get_text() + " -/-> " + items[1].get_text() + "\n"
	return output


func free() -> void:
	for edge: Clue in _positive_clues:
		edge.free()
	for item: Item in _items:
		item.free()
