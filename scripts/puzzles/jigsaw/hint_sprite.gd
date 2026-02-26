class_name PuzzleHint
extends Polygon2D

var spriteDict : Dictionary = {
	0:
		{"type1":"res://icon.svg","type2": "res://icon.svg"}
}
var hintColors : Dictionary = {};
class spriteData:
	var pos: Vector2;
	var path: String;
	var size: Vector2;
	func _init(path : String, pos : Vector2 = Vector2(0,0), size : Vector2 = Vector2(1,1)) -> void:
		self.path = path;
		self.pos = pos;
		self.size = size;
var typeToSprite : Dictionary = {
	"true":spriteData.new("res://assets/textures/positive.png"),
	"false":spriteData.new("res://assets/textures/negative.png"),
	"triangle_button":spriteData.new("res://assets/textures/triangle_button.png"),
	"circle_button":spriteData.new("res://assets/textures/circle_button.png"),
	"square_button":spriteData.new("res://assets/textures/square_button.png"),
	"press":spriteData.new("res://assets/textures/press.png",Vector2(-5,-5)),
	"hold":spriteData.new("res://assets/textures/hold.png",Vector2(-5,-5)),
	"times":spriteData.new("res://assets/textures/times.png",Vector2(7,3),Vector2(0.5,0.5)),
	"seconds":spriteData.new("res://assets/textures/seconds.png",Vector2(7,3),Vector2(0.5,0.5)),
	"hashtag":spriteData.new("res://assets/textures/hashtag.png",Vector2(-7,0)),
	"1":spriteData.new("res://assets/textures/1.png",Vector2(2,5),Vector2(0.6,0.6)),
	"2":spriteData.new("res://assets/textures/2.png",Vector2(2,5),Vector2(0.6,0.6)),
	"3":spriteData.new("res://assets/textures/3.png",Vector2(2,5),Vector2(0.6,0.6)),
	"4":spriteData.new("res://assets/textures/4.png",Vector2(2,5),Vector2(0.6,0.6)),
	"5":spriteData.new("res://assets/textures/5.png",Vector2(2,5),Vector2(0.6,0.6)),
	
	"1centered":spriteData.new("res://assets/textures/1.png"),
	"2centered":spriteData.new("res://assets/textures/2.png"),
	"3centered":spriteData.new("res://assets/textures/3.png"),
	"4centered":spriteData.new("res://assets/textures/4.png"),
	"5centered":spriteData.new("res://assets/textures/5.png"),
	"triangle_port":spriteData.new("res://assets/textures/triangle_port.png",Vector2(0,0)),
	"circle_port":spriteData.new("res://assets/textures/circle_port.png",Vector2(0,0)),
	"square_port":spriteData.new("res://assets/textures/square_port.png",Vector2(0,0)),
	"button":spriteData.new("res://assets/textures/button.png",Vector2(0,0)),
	"wire":spriteData.new("res://assets/textures/wire.png",Vector2(0,0)),
	"roman1":spriteData.new("res://assets/textures/roman1.png",Vector2(0,0)),
	"roman2":spriteData.new("res://assets/textures/roman2.png",Vector2(0,0)),
	"roman3":spriteData.new("res://assets/textures/roman3.png",Vector2(0,0)),
}
# a clue is made up of two items and a bool
# an item is made up of an array of sprites 
var clues : Array = [
	[["hashtag","1centered"],["positive"],["circle_button"]],
	[["roman1"],["negative"],["square_button"]],
	[["triangle_port"],["positive"],["triangle_button"]],
	[["hold"],["positive"],["circle_port"]],
	[["hold","1","times"],["positive"],["square_port"]],
];

#array of clues
#clues are comprised of 2 items and a positive
func construct(poly : PackedVector2Array, seed : int) -> void:
	seed(seed);
	polygon = poly;
	var numClues : int = clues.size();
	var canvasSize : Vector2 = $Sprite2D.get_rect().size;
	var canvasY : float = canvasSize[1];
	#Y space item space item space.. item * itemsize + space * (item + 1)
	#space = itemsize/2
	#item * itemsize + itemsize/2 * (item + 1)
	#(3/2 * item + 1/2) * itemsize = canvasY
	#canvasY/(3/2 * item + 1/2) = itemsize;
	#if item == 5
	#canvasY/(8) = itemsize
	var itemSize : float = canvasY/(1.5 * numClues + 0.5)
	#rescale item to fit size
	var linePoints : Array = [];
	var currentY : float = 0;
	var currentX : float = 0;
	var currentSprite : Resource = load("res://icon.svg");
	
	currentY = 0.5 * itemSize;
	print("clues")
	print(clues)
	for n : int in clues.size(): # clues[n] is an array
		var temp : Array = clues[n].duplicate()
		
		var gapspace : float = (canvasSize[0] - clues[n].size() * itemSize)/(clues[n].size() + 1);
		currentX = gapspace;
		linePoints.append(currentY)
		temp.reverse();
		for x : int in temp.size(): #clues[n][x] is an array
			for y: int in temp[x].size():
				var tempsprite : Sprite2D = Sprite2D.new();
				tempsprite.texture = load(typeToSprite[temp[x][y]].path);
				tempsprite.scale = typeToSprite[temp[x][y]].size * itemSize / tempsprite.get_rect().size[1]
				tempsprite.flip_h = true;
				add_child(tempsprite);
				if hintColors.has(temp[x][y]):
					tempsprite.modulate = hintColors[temp[x][y]];
				tempsprite.position = Vector2(currentX + itemSize/2.0,currentY + itemSize/2.0) - typeToSprite[temp[x][y]].pos;
				#print(currentY)
			
			currentX += 1 * itemSize;
			currentX += gapspace;
		currentY += 1.5 * itemSize;
		
	#print(linePoints)
