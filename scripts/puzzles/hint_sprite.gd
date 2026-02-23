extends Polygon2D

var spriteDict : Dictionary = {
	"data1":
		{"type1":"res://icon.svg","type2": "res://icon.svg"}
}
var arrow : Array = ["res://icon.svg"];
var clues : Array = [
	[{"data":"data1","type":"type1"},{"data":"data1","type":"type2"}],
	[{"data":"data1","type":"type1"},{"data":"data1","type":"type1"}],
	[{"data":"data1","type":"type1"},{"data":"data1","type":"type1"}],
	[{"data":"data1","type":"type1"},{"data":"data1","type":"type1"}],
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
	
	for n : int in numClues:
		var spriteArr : Array = [
			spriteDict[clues[n][0].data][clues[n][0].type],
			#arrow[0],
			spriteDict[clues[n][1].data][clues[n][1].type],
		];
		spriteArr.reverse();
		#gapspace = (canvasSize[0] - spriteArr.size() * itemSize)/(spriteArr.size() + 1);
		currentX = (canvasSize[0] - spriteArr.size() * itemSize)/(spriteArr.size() + 1);
		linePoints.append(currentY)
		
		
		
		for x in spriteArr.size():
			var tempsprite : Sprite2D = Sprite2D.new();
			tempsprite.texture = load(spriteArr[x]);
			tempsprite.scale = Vector2(1,1) * itemSize / tempsprite.get_rect().size[1]
			tempsprite.flip_h = true;
			add_child(tempsprite);
			tempsprite.position = Vector2(currentX + itemSize/2.0,currentY + itemSize/2.0);
			print(currentY)
			currentX += 1 * itemSize;
			currentX += (canvasSize[0] - spriteArr.size() * itemSize)/(spriteArr.size() + 1);
		currentY += 1.5 * itemSize;
		
	print(linePoints)
