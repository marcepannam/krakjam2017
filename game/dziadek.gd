extends Node2D

const X_TOLERANCE = 10

var staff_base_offset
var staff
var staff_angle = 0
var staff_circle_radius = 250
var staff_rps = 1.5
var staff_target

var target_platform

var jump_speed = 3500

const WAITING = 0
const AIMING = 1
const STAFF_ANIM = 2
const JUMPING = 3
const DEATH = 4

# AIMING -> STAFF_ANIM -> WAITING -> JUMPING -> AIMING

var gameTime = 0
var state = WAITING
var hero_width = 341
var animation_player
var side = 1
var root
var body
var camera
var background
var is_space_pressed = false
var menu_scene = preload("res://menu.tscn")
var staff_end

func _ready():
	set_process(true)
	set_process_input(true)
	camera = get_node("/root/Control/Camera2D")
	staff = get_node("shoulder_staff/staff")
	body = get_node("hip/body")
	root = get_node("/root")
	staff_base_offset = staff.get_global_pos() - get_global_pos()
	animation_player = get_node("AnimationPlayer")
	background = get_node("/root/Control/level_background/CanvasLayer/background")
	start_waiting()
	
func start_waiting():
	print("ready ", get_global_pos())
	state = AIMING
	# Should we rotate? Count platforms on the right and above.
	check_side()
	set_scale(Vector2(side, 1))
	staff.set_scale(Vector2(side, 1))

func cmp(a, b):
	return a[0] > b[0]

func get_next_platform():
	if target_platform == null: return
	var ordered = []
	for platform in get_node("/root").get_tree().get_nodes_in_group("platform"):
		ordered.append([platform.get_pos().y, platform])
	ordered.sort_custom(self, "cmp")
	
	var myIndex = null
	var i = 0
	for t in ordered:
		var platform = t[1]
		#print(t[0], " ", platform.get_name(), " ", platform.get_pos())
		if platform == target_platform: myIndex = i
		i += 1
	
	if myIndex == null:
		print("my platform not found")
		return
	
	if myIndex == ordered.size() - 1:
		print("WIN!")
		return

	return ordered[myIndex+1][1]

func check_side():
	if target_platform == null: return
	
	var next_platform = get_next_platform()
	if next_platform == null:
		win()
		return
	
	if next_platform.get_pos().x > target_platform.get_pos().x:
		side = 1
	else:
		side = -1

func win():
	pass

func arr_interpolate(arr, v):
	#print(arr, v)
	for i in range(arr.size() - 1):
		if v >= arr[i][0] && v < arr[i+1][0]:
			var alpha = (v - arr[i][0]) / float(arr[i+1][0] - arr[i][0])
			return (1-alpha) * arr[i][1] + alpha * arr[i+1][1]
	return arr[0][1]

func _draw():
	if staff_end != null:
		draw_rect(Rect2(staff_end.x * side, staff_end.y, 20, 20), Color(1, 0, 0))

func _process(delta):
	camera.set_global_pos(Vector2(camera.get_global_pos().x, get_global_pos().y))
	gameTime += delta
	
	var player_y = -get_global_pos().y
	
	var steps = [[-3000, 0], [-300, 0], [0, 10], [2000, 20], [10000, 30], [25000, 40], [1000000, 40]]
	var rotation_amplitude = arr_interpolate(steps, player_y)
	var rotation_period = 3
		
	var rot = sin(gameTime / rotation_period * 3.1415 * 2) * rotation_amplitude
	var bgsize = background.get_item_rect().end
	camera.set_rotd(rot + 180)
	body.set_rotd(rot)
	
	var staff_offset = Vector2(staff_base_offset.x * side, staff_base_offset.y).rotated(body.get_rot())
	
	staff.set_rotd(rot)
	
	staff_end = staff.get_global_pos() - get_global_pos()
	var staff_vec = Vector2(0, staff.get_item_rect().size.y)
	if side == -1: staff_vec.x = -staff.get_item_rect().size.x + 7
	staff_end += staff_vec.rotated(staff.get_rot() * side)
	# update()
	
	if state == AIMING:
		if not animation_player.is_playing():
			animation_player.play(["stand", "stand2", "stand3"][randi() % 3])

		if target_platform != null:
			set_global_pos(get_platform_target(target_platform))
		staff_angle -= staff_rps * 3.1415 * 2 * delta * side
		var staff_pos = get_global_pos() + staff_offset + Vector2(staff_circle_radius, 0).rotated(staff_angle)
		staff.set_global_pos(staff_pos)
	elif state == WAITING:
		staff.set_global_pos(get_global_pos() + staff_offset)
	elif state == STAFF_ANIM:
		var staff_speed = 800 + player_y / 10
		var vdelta = staff.get_global_pos() - staff_target
		if vdelta.length() < delta * staff_speed:
			if not is_space_pressed:
				start_jump()
			return
		var new_pos = staff.get_global_pos() + vdelta.normalized() * -staff_speed * delta
		staff.set_global_pos(new_pos)
	elif state == JUMPING:
		jump_progress += delta * jump_speed
		var jump_length = (jump_target - jump_start).length()
		if jump_progress > jump_length:
			start_waiting()
			return
		
		var staff_target_pos = jump_target + staff_offset
		staff.set_global_pos(jump_staff_start.linear_interpolate(staff_target_pos, jump_progress / jump_length))
		set_global_pos(jump_start.linear_interpolate(jump_target, jump_progress / jump_length))
	elif state == DEATH:
		falling_speed += delta * 50
		var pos = get_global_pos()	
		if pos.y > 2900:
			print("go to menu")
			get_tree().change_scene_to(menu_scene)
			return
		pos.y += falling_speed
		pos.x += side * 20
		set_global_pos(pos)
		
		var staff_pos = staff.get_pos()
		staff_pos.y += 40 * delta;
		staff.set_pos(staff_pos)
		
		if not animation_player.is_playing():
			animation_player.play("falling")

var falling_speed = -20

var jump_target
var jump_start
var jump_progress
var jump_staff_start

func get_platform_target(platform):
	var me_delta = Vector2(120, -530)
	var platform_width = platform.get_item_rect().size.width / 2
	var platform_pos = platform.get_global_pos() + platform.get_item_rect().pos
	return platform_pos + Vector2(platform_width / 2, 0) + me_delta
	
func start_jump():
	jump_progress = 0
	jump_start = get_global_pos()
	jump_staff_start = staff.get_global_pos()
	jump_target = get_platform_target(target_platform)
	state = JUMPING
	
func do_action():
	# AIMING -> STAFF_ANIM
	var STAFF_HEIGHT = 800
	print("do action ", staff.get_global_pos() + Vector2(0, STAFF_HEIGHT))
	var current_platform = target_platform
	target_platform = find_platform_at(get_global_pos() + staff_end)
	
	if target_platform == null:
		die()
		return # die
	else:
		print("target: ", target_platform.get_name())
		if current_platform != null && target_platform.get_pos().y > current_platform.get_pos().y:
			die()
			return
		state = STAFF_ANIM
		staff_target = staff.get_global_pos()
		var staff_height = staff.get_item_rect().size.y * get_scale().y
		staff_target.y = target_platform.get_item_rect().pos.y * target_platform.get_scale().y + target_platform.get_global_pos().y - staff_height

func die():
	print("die :( at ", get_global_pos())
	state = DEATH
	animation_player.play("slipping")

func _input(event):
	if event.type == InputEvent.KEY and event.scancode == KEY_Q:
		target_platform = get_next_platform()
		staff_target = staff.get_global_pos()
		state = STAFF_ANIM
		return
		
	if event.type == InputEvent.KEY and event.scancode == KEY_SPACE:
		if event.pressed == true:
			is_space_pressed = true
			if state == AIMING:
				do_action()
		else:
			is_space_pressed = false
			if state == WAITING:
				do_jump()
# utils

func find_platform_at(pos):
	var platforms = get_node("/root").get_tree().get_nodes_in_group("platform")
	var best_y_dist = 100000
	var best_platform = null
	for platform in platforms:
		var bpos = platform.get_global_pos()
		var rect = platform.get_item_rect()
		var scale = platform.get_scale()
		if pos.x > bpos.x + rect.pos.x * scale.x and pos.x < bpos.x + rect.end.x * scale.x:
			var y_dist = (bpos.y + rect.pos.y * scale.y) - pos.y
			if y_dist > -110 and y_dist < best_y_dist and y_dist < 500:
				best_y_dist = y_dist
				best_platform = platform
	print("BEST: ",best_y_dist)
	return best_platform
