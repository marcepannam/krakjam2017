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

var STAFF_SPEED = 1000
var JUMP_SPEED = 3500
var ROTATION_PERIOD = 3

const WAITING = 0
const STAFF_ANIM = 1
const JUMPING = 2

var gameTime = 0
var state = WAITING
var hero_width = 341
var animation_player
var side = 1
var body
var camera

func _ready():
	set_process(true)
	set_process_input(true)
	camera = get_node("/root/Control/Camera2D")
	staff = get_node("shoulder_staff/arm_staff/staff")
	body = get_node("hip/body")
	staff_base_offset = staff.get_global_pos() - get_global_pos()
	animation_player = get_node("AnimationPlayer")
	start_waiting()
	
func start_waiting():
	state = WAITING
	# Should we rotate? Count platforms on the right and above.
	check_side()
	set_scale(Vector2(side, 1))
	staff.set_scale(Vector2(side, 1))

func check_side():
	if target_platform == null: return
	var platforms = get_node("/root").get_tree().get_nodes_in_group("platform")
	var current_pos = target_platform.get_pos() + target_platform.get_item_rect().pos
	var ok = false
	for platform in platforms:
		var this_pos = platform.get_pos() + platform.get_item_rect().pos
		if this_pos.y < current_pos.y:
			if side == 1 and this_pos.x > current_pos.x: ok = true
			if side == -1 and this_pos.x < current_pos.x: ok = true
		
	if not ok:
		side *= -1

func _process(delta):
	camera.set_global_pos(Vector2(camera.get_global_pos().x, get_global_pos().y))
	gameTime += delta 
	var rot = sin(gameTime / ROTATION_PERIOD * 3.1415 * 2) * 20
	camera.set_rotd(rot + 180)
	body.set_rotd(rot)
	if state == WAITING:
		if not animation_player.is_playing():
			animation_player.play(["stand", "stand2", "stand3"][randi() % 3])

		staff_angle -= staff_rps * 3.1415 * 2 * delta
		var staff_offset = Vector2(staff_base_offset.x * side, staff_base_offset.y)
		var staff_pos = get_global_pos() + staff_offset + Vector2(staff_circle_radius, 0).rotated(staff_angle)
		staff.set_global_pos(staff_pos)
	elif state == STAFF_ANIM:
		var vdelta = staff.get_global_pos() - staff_target
		if vdelta.length() < delta * STAFF_SPEED:
			start_jump()
			return
		var new_pos = staff.get_global_pos() + vdelta.normalized() * -STAFF_SPEED * delta
		staff.set_global_pos(new_pos)
	elif state == JUMPING:
		jump_progress += delta * JUMP_SPEED
		var jump_length = (jump_target - jump_start).length()
		if jump_progress > jump_length:
			start_waiting()
			return
		
		var staff_target_pos = jump_target + Vector2(staff_circle_radius + staff_base_offset.x * side, staff_base_offset.y)
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
	var me_delta = Vector2(-100, -450)
	var platform_pos = target_platform.get_global_pos() + target_platform.get_item_rect().pos
	jump_target = platform_pos + Vector2(platform_width, 0) + me_delta
	state = JUMPING
	
func do_action():
	print(get_pos())
	var STAFF_HEIGHT = 800
	print("do action ", staff.get_global_pos() + Vector2(0, STAFF_HEIGHT))
	target_platform = find_platform_at(staff.get_global_pos() + Vector2(0, STAFF_HEIGHT))
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
			var y_dist = pos.y - (bpos.y + rect.pos.y * scale.y)
			print(bpos.y, " ", rect.pos.y, " ", platform.get_name(), " ", y_dist)
		
			if y_dist > Y_TOLERANCE and y_dist < best_y_dist:
				best_y_dist = y_dist
				best_platform = platform
	return best_platform
