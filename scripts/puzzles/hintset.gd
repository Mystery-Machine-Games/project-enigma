class_name HintSet
extends Object

var _hints: Array[Hint]


func _init(clueset: Clueset, interaction: String) -> void:
	# TODO:
	# for each clue in clueset:
	# - initialize hint in the format [["circle_button"], true, ["press", "3", "times"]]
	# - use the interaction string to determine "press" and "times" vs. "hold" and <whatever the clock code is>
	# - add hint to _hints
	pass


func get_hints() -> Array[Hint]:
	return _hints
