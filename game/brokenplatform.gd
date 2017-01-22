extends Sprite

var hero
var game_time = 2
var base_pos

func _ready():
	hero = get_node("/root/Control/dziadek")
	hero.connect("platform_changed", self, "changed")
	base_pos = get_global_pos()

func _process(delta):
	game_time -= delta
	if game_time < 0:
		hero.die_base()
		set_self_opacity(0)
		
	var pos = base_pos + Vector2(sin(game_time * 10 * 3.1415 * 2) * 10, 0)
	set_global_pos(pos)

func changed(new_platform):
	if new_platform == self:
		print("this")
		set_process(true)
	else:
		set_process(false)