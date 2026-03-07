class_name PuzzleHint
extends Polygon2D

var spriteDict : Dictionary = {
	0:
		{"type1":"res://icon.svg","type2": "res://icon.svg"}
}

# a clue is made up of two items and a bool
# an item is made up of an array of sprites 
var clues : Array = [
	[["hashtag","1centered"],["positive"],["circle_button"]],
	[["roman1"],["negative"],["square_button"]],
	[["triangle_port"],["positive"],["triangle_button"]],
	[["hold"],["positive"],["circle_port"]],
	[["hold","1","times"],["positive"],["square_port"]],
];#array of clues
var header : Array = [];

var hintColors : Dictionary = {};


func construct(poly : PackedVector2Array, seed : int,flipped : bool = true) -> void:
	#seed(seed);
	if poly.size() > 0:
		polygon = poly;
	var numClues : int = clues.size() + 1;
	var canvasSize : Vector2 = $Sprite2D.get_rect().size;
	var canvasY : float = canvasSize[1];
	var itemSize : float = canvasY/(1.5 * numClues + 0.5)
	#rescale item to fit size
	var linePoints : Array = [];
	var currentY : float = 0;
	var currentX : float = 0;
	
	currentY = 1.5 * itemSize;
	for n : int in clues.size(): # clues[n] is an array
		var temp: Array = clues[n].duplicate()
		
		var gapspace : float = (canvasSize[0] - clues[n].size() * itemSize)/(clues[n].size() + 1);
		currentX = gapspace;
		linePoints.append(currentY)
		if flipped:
			temp.reverse();
		for x : int in temp.size(): #clues[n][x] is an array
			for y: int in temp[x].size():
				var tempsprite : Sprite2D = Sprite2D.new();
				var sprite_data: SpriteData = TypeSpriteDictionary.type_to_sprite(temp[x][y])
				tempsprite.texture = load(sprite_data.get_path())
				tempsprite.scale = sprite_data.get_size() * itemSize / tempsprite.get_rect().size[1]
				if flipped:
					tempsprite.flip_h = true;
				add_child(tempsprite);
				if hintColors.has(temp[x][y]):
					tempsprite.modulate = hintColors[temp[x][y]];
				tempsprite.position = Vector2(currentX + itemSize/2.0,currentY + itemSize/2.0) - sprite_data.get_pos();
			
			currentX += 1 * itemSize;
			currentX += gapspace;
		currentY += 1.5 * itemSize;
	var gapspace : float = (canvasSize[0] - header.size() * itemSize)/(header.size() + 1);
	currentX = gapspace * 0.5;
	var temp2 : Array = header.duplicate();
	if flipped:
		temp2.reverse();
	for n : int in header.size():
		var tempsprite : Sprite2D = Sprite2D.new();
		var sprite_data: SpriteData = TypeSpriteDictionary.type_to_sprite(temp2[n])
		tempsprite.texture = load(sprite_data.get_path())
		tempsprite.scale = sprite_data.get_size() * itemSize / tempsprite.get_rect().size[1]
		if flipped:
			tempsprite.flip_h = true;
		add_child(tempsprite);
		tempsprite.position = Vector2(currentX + itemSize/2.0,itemSize * 1) - sprite_data.get_pos();
		currentX += 1 * itemSize;
