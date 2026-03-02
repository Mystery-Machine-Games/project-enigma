class_name TypeSpriteDictionary
extends Object

static var _sprite_types : Dictionary = {
	"true":SpriteData.new("res://assets/textures/positive.png"),
	"false":SpriteData.new("res://assets/textures/negative.png"),
	"triangle_button":SpriteData.new("res://assets/textures/triangle_button.png"),
	"circle_button":SpriteData.new("res://assets/textures/circle_button.png"),
	"square_button":SpriteData.new("res://assets/textures/square_button.png"),
	"press":SpriteData.new("res://assets/textures/press.png",Vector2(-5,-5)),
	"hold":SpriteData.new("res://assets/textures/hold.png",Vector2(-5,-5)),
	"times":SpriteData.new("res://assets/textures/times.png",Vector2(7,3),Vector2(0.5,0.5)),
	"seconds":SpriteData.new("res://assets/textures/seconds.png",Vector2(7,3),Vector2(0.5,0.5)),
	"hashtag":SpriteData.new("res://assets/textures/hashtag.png",Vector2(-7,2),Vector2(0.7, 0.7)),
	"1":SpriteData.new("res://assets/textures/1.png",Vector2(2,5),Vector2(0.6,0.6)),
	"2":SpriteData.new("res://assets/textures/2.png",Vector2(2,5),Vector2(0.6,0.6)),
	"3":SpriteData.new("res://assets/textures/3.png",Vector2(2,5),Vector2(0.6,0.6)),
	"4":SpriteData.new("res://assets/textures/4.png",Vector2(2,5),Vector2(0.6,0.6)),
	"5":SpriteData.new("res://assets/textures/5.png",Vector2(2,5),Vector2(0.6,0.6)),
	
	"1centered":SpriteData.new("res://assets/textures/1.png"),
	"2centered":SpriteData.new("res://assets/textures/2.png"),
	"3centered":SpriteData.new("res://assets/textures/3.png"),
	"4centered":SpriteData.new("res://assets/textures/4.png"),
	"5centered":SpriteData.new("res://assets/textures/5.png"),
	"triangle_port":SpriteData.new("res://assets/textures/triangle_port.png",Vector2(0,0)),
	"circle_port":SpriteData.new("res://assets/textures/circle_port.png",Vector2(0,0)),
	"square_port":SpriteData.new("res://assets/textures/square_port.png",Vector2(0,0)),
	"button":SpriteData.new("res://assets/textures/button.png",Vector2(0,0)),
	"wire":SpriteData.new("res://assets/textures/wire.png",Vector2(0,0)),
	"roman1":SpriteData.new("res://assets/textures/roman1.png",Vector2(0,0)),
	"roman2":SpriteData.new("res://assets/textures/roman2.png",Vector2(0,0)),
	"roman3":SpriteData.new("res://assets/textures/roman3.png",Vector2(0,0)),
}


static func type_to_sprite(type: String) -> SpriteData:
	return _sprite_types[type]
