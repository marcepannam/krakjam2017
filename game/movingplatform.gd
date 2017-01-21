extends Sprite

var base_pos
var game_time = 0
var period = 2
var distance = 2

func _ready():
	print("ready")
	base_pos = get_global_pos()
	set_process(true)

func _process(delta):
	game_time += delta
	var d = (game_time / period) 
	d = fmod(d, 2)
	if d > 1: d = 2 - d
	d = d * 2 - 1
	var pos = Vector2(base_pos.x + (distance * get_item_rect().size.x) * d, base_pos.y)
	set_global_pos(pos)