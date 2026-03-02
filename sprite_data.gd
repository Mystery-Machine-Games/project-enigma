class_name SpriteData
extends Object

var _pos: Vector2
var _path: String
var _size: Vector2


func _init(path: String, pos : Vector2 = Vector2(0,0), size : Vector2 = Vector2(1,1)) -> void:
	_path = path
	_pos = pos
	_size = size


func get_pos() -> Vector2: return _pos


func get_path() -> String: return _path


func get_size() -> Vector2: return _size
