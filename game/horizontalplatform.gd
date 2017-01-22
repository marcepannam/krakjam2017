extends Sprite

var base_pos
var distance = 2
var hero

func _ready():
	print("ready")
	base_pos = get_global_pos()
	set_process(true)
	hero = get_node("/root/Control/dziadek")

func _process(delta):
	var d = hero.rot_base
	var pos = Vector2(base_pos.x, base_pos.y + (distance * get_item_rect().size.x) * d)
	set_global_pos(pos)