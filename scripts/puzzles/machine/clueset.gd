class_name Clueset
extends Object

var _items: Array[Item]
var _assumption_items: Array[Item] # Vertices unconnected to any other vertices
var _clues: Array[Clue]


func add_item(category: String, data: Variant, codes: Array[String], text: String = "", head: bool = false) -> Item:
	var new_item: Item = Item.new(category, data, codes, text, head)
	_items.append(new_item)
	_assumption_items.append(new_item)
	return new_item


func remove_item() -> void:
	pass # TODO


func add_clue(item1: Item, item2: Item, positive: bool = true) -> Clue:
	var new_clue: Clue = Clue.new(item1, item2, positive)
	_clues.append(new_clue)
	var item1_assumption_index: int = _assumption_items.find(item1)
	var item2_assumption_index: int = _assumption_items.find(item2)
	if item1_assumption_index != -1: _assumption_items.remove_at(item1_assumption_index)
	if item2_assumption_index != -1: _assumption_items.remove_at(item2_assumption_index)
	return new_clue


func remove_edge() -> void:
	pass # TODO


func find_item(text: String) -> Item:
	for item: Item in _items:
		if item.get_text() == text:
			return item
	return null


func pick_random_assumption_item() -> Item:
	_assumption_items.shuffle()
	for item: Item in _assumption_items:
		if !item.is_head():
			return item
	push_error("[CLUESET][ERROR] Couldn't find random assumption item")
	return null


func pick_random_positive_clue(category: String) -> Clue:
	_clues.shuffle()
	for clue: Clue in _clues:
		if clue.get_items()[1].get_category() == category:
			return clue
	push_error("[CLUESET][ERROR] Couldn't find random positive clue")
	return null


# Replaces a random positive clue with a negative clue using an item from the assumption
func assumption_replacement() -> Clue:
	# Pick random assumption item
	var assumption_item: Item = pick_random_assumption_item()
	# Pick random positive clue ending in the same category as the assumption item
	var assumption_item_category: String = assumption_item.get_category()
	var clue: Clue = pick_random_positive_clue(assumption_item_category)
	
	clue.set_items(clue.get_items()[0], assumption_item)
	clue.set_positive(false)
	# Remember to remove item from assumption so it isn't used again
	var assumption_item_index: int = _assumption_items.find(assumption_item)
	_assumption_items.remove_at(assumption_item_index)
	return clue


# Replaces a random positive clue with multiple negative clues
# Debating on whether to add this or not because it may make puzzles more frustrating than anything
func negatives_replacement() -> void:
	# TODO
	# Choose random positive clue
	# Need a list of items of the same type as item1 of this clue (excluding item1)
	# Replace origin item with one of these items of the same type
	# Make clue negative
	# For every other item in list of items of the same type, create a negative clue
	pass


func get_assumption_items() -> Array[Item]:
	return _assumption_items


func get_clues() -> Array[Clue]:
	return _clues


func _to_string() -> String:
	var output: String = ""
	for clue: Clue in _clues:
		var items: Array[Item] = clue.get_items()
		if items.size() == 2:
			if clue.is_positive(): output += items[0].get_text_with_codes() + " --> " + items[1].get_text_with_codes() + "\n"
			else: output += items[0].get_text_with_codes() + " -/-> " + items[1].get_text_with_codes() + "\n"
		else:
			print("[CLUESET][TO_STRING] Error: clue does not have 2 items")
	return output


func free() -> void:
	for edge: Clue in _clues: edge.free()
	for item: Item in _items: item.free()
