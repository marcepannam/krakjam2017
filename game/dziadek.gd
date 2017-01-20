extends Node2D

const Y_TOLERANCE = 10

var staff_base_pos
var staff
var staff_angle = 0
var staff_circle_radius = 50
var staff_rps = 0.5
var staff_target

var target_platform

const WAITING = 0
const STAFF_ANIM = 1
const JUMPING = 2

var state = WAITING

func _ready():
	set_process(true)
	set_process_input(true)
	staff = get_node("body/Node2D/arm_staff/staff")
	staff_base_pos = staff.get_global_pos()
	
func _process(delta):
	if state == WAITING:
		staff_angle -= staff_rps * 3.1415 * 2 * delta
		var staff_pos = staff_base_pos + Vector2(staff_circle_radius, 0).rotated(staff_angle)
		staff.set_global_pos(staff_pos)
	elif state == STAFF_ANIM:
		var STAFF_SPEED = 3
		var delta = staff.get_global_pos() - staff_target
		if delta.length() < 5:
			start_jump()
			return
		var new_pos = staff.get_global_pos() + delta.normalized() * -STAFF_SPEED
		staff.set_global_pos(new_pos)
	elif state == JUMPING:
		jump_progress += delta * 100
		var jump_length = (jump_target - jump_start).length()
		if jump_progress > jump_length:
			state = WAITING
			return
		
		set_global_pos(jump_start.linear_interpolate(jump_target, jump_progress / jump_length))

var jump_target
var jump_start
var jump_progress

func start_jump():
	var platform_width = target_platform.get_item_rect().size.width / 2
	jump_progress = 0
	jump_start = get_global_pos()
	var me_delta = Vector2(10, -120)
	jump_target = target_platform.get_global_pos() + Vector2(platform_width, 0) + me_delta
	state = JUMPING
	
func do_action():
	print("do action")
	target_platform = find_platform_at(staff.get_global_pos())
	print("target: ", target_platform)
	if target_platform == null:
		return # die
	else:
		state = STAFF_ANIM
		staff_target = staff.get_global_pos()
		var staff_height = staff.get_item_rect().size.y * get_scale().y
		staff_target.y = (target_platform.get_item_rect().pos + target_platform.get_global_pos() ).y - staff_height

func _input(event):
	if event.type == InputEvent.KEY and event.scancode == KEY_SPACE && event.pressed == true:
		do_action()

# utils

func find_platform_at(pos):
	var platforms = get_node("/root").get_tree().get_nodes_in_group("platform")
	var best_y_dist = 100000
	var best_platform = null
	for platform in platforms:
		var bpos = platform.get_global_pos()
		var rect = platform.get_item_rect()
		print(rect, " ", bpos, " ", pos)
		if pos.x > (bpos + rect.pos).x and pos.x < (bpos + rect.end).x:
			var y_dist = pos.y - rect.pos.y
			if y_dist > Y_TOLERANCE and y_dist < best_y_dist:
				best_y_dist = y_dist
				best_platform = platform
	return best_platform
