extends Node2D

const Y_TOLERANCE = 10
const X_TOLERANCE = 10

var staff_base_offset
var staff
var staff_angle = 0
var staff_circle_radius = 250
var staff_rps = 1.5
var staff_target

var target_platform

var STAFF_SPEED = 10
var JUMP_SPEED = 500

const WAITING = 0
const STAFF_ANIM = 1
const JUMPING = 2

var state = WAITING
var hero_width = 341
var animation_player

func _ready():
	set_process(true)
	set_process_input(true)
	staff = get_node("shoulder_staff/arm_staff/staff")
	staff_base_offset = staff.get_global_pos() - get_global_pos()
	animation_player = get_node("AnimationPlayer")
	
func _process(delta):
	if state == WAITING:
		if not animation_player.is_playing():
			animation_player.play("stand")
		staff_angle -= staff_rps * 3.1415 * 2 * delta
		var staff_pos = get_global_pos() + staff_base_offset + Vector2(staff_circle_radius, 0).rotated(staff_angle)
		staff.set_global_pos(staff_pos)
	elif state == STAFF_ANIM:
		var delta = staff.get_global_pos() - staff_target
		if delta.length() < 5:
			start_jump()
			return
		var new_pos = staff.get_global_pos() + delta.normalized() * -STAFF_SPEED
		staff.set_global_pos(new_pos)
	elif state == JUMPING:
		jump_progress += delta * JUMP_SPEED
		var jump_length = (jump_target - jump_start).length()
		if jump_progress > jump_length:
			state = WAITING
			return
		
		var staff_target_pos = jump_target + staff_base_offset + Vector2(staff_circle_radius, 0)
		staff.set_global_pos(jump_staff_start.linear_interpolate(staff_target_pos, jump_progress / jump_length))
		set_global_pos(jump_start.linear_interpolate(jump_target, jump_progress / jump_length))

var jump_target
var jump_start
var jump_progress
var jump_staff_start

func start_jump():
	var platform_width = target_platform.get_item_rect().size.width / 2
	jump_progress = 0
	jump_start = get_global_pos()
	jump_staff_start = staff.get_global_pos()
	var me_delta = Vector2(-20, -120)
	var platform_pos = target_platform.get_global_pos() + target_platform.get_item_rect().pos
	jump_target = platform_pos + Vector2(platform_width, 0) + me_delta
	state = JUMPING
	
func do_action():
	print(get_pos())
	print("do action")
	target_platform = find_platform_at(staff.get_global_pos())
	if target_platform != null:
		print("target: ", target_platform.get_name())
	if target_platform == null:
		print("die")
		return # die
	else:
		state = STAFF_ANIM
		staff_target = staff.get_global_pos()
		var staff_height = staff.get_item_rect().size.y * get_scale().y
		staff_target.y = target_platform.get_item_rect().pos.y * target_platform.get_scale().y + target_platform.get_global_pos().y - staff_height

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
		var scale = platform.get_scale()
		
		if pos.x + X_TOLERANCE > bpos.x + rect.pos.x * scale.x and pos.x - X_TOLERANCE < bpos.x + rect.end.x * scale.x:
			var y_dist = pos.y - rect.pos.y
			if y_dist > Y_TOLERANCE and y_dist < best_y_dist:
				best_y_dist = y_dist
				best_platform = platform
	return best_platform
