extends Sprite

# No lighthouse for old sailor
# Those damn waves

var Y_TOLERANCE = 10

var timeSinceLastAction = 100000.0

func _ready():
	print("ready")
	set_process(true)
	set_process_input(true)

func _process(delta):
	var pos = self.get_pos()
	pos.x += delta * 20
	self.set_pos(pos)

func do_action():
	print("do action")
	
	
func _input(event):
	if event.type == InputEvent.KEY and event.scancode == KEY_SPACE && event.pressed == true:
		do_action()

# === utils ====

func find_platform_at(pos):
	var platforms = get_tree().get_nodes_in_group("platform")
	var best_y_dist = 100000
	var best_platform = null
	for platform in platforms:
		var rect = platform.get_item_rect()
		if pos.x > rect.pos.x and pos.x < rect.end.x:
			var y_dist = rect.pos.y - pos.y
			if y_dist > Y_TOLERANCE and y_dist < best_y_dist:
				best_y_dist = y_dist
				best_platform = platform
	return best_platform
