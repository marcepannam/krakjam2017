extends Sprite

# No lighthouse for old sailor
# Those damn waves

var timeSinceLastAction

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