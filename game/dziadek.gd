extends Node2D

const X_TOLERANCE = 10

var staff_base_offset
var staff
var staff_angle = 0
var staff_circle_radius = 250
var staff_rps = 1.5
var staff_target
var dziadek_sounds

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
var staff_begin
var shoulder_ref
var staff_ref
var staff_hand
var ordered
var rot_base = 0

signal platform_changed

func _ready():
	set_process(true)
	set_process_input(true)
	camera = get_node("/root/Control/Camera2D")
	staff = get_node("shoulder_staff/staff")
	body = get_node("hip/body")
	root = get_node("/root")
	dziadek_sounds = get_node("dziadek_sounds")
	staff_base_offset = staff.get_global_pos() - get_global_pos()
	animation_player = get_node("AnimationPlayer")
	background = get_node("/root/Control/level_background/CanvasLayer/background")
	shoulder_ref = get_node("hip/body/shoulder_staff_ref")
	staff_ref = get_node("shoulder_staff/staff/staff_begin")
	staff_hand = get_node("shoulder_staff/arm_staff")
	start_waiting()
	
	sort_platforms()
	
func sort_platforms():
	ordered = []
	for platform in get_node("/root").get_tree().get_nodes_in_group("platform"):
		ordered.append([platform.get_pos().y, platform])
	ordered.sort_custom(self, "cmp")
	
func start_waiting():
	print("ready ", get_global_pos())
	emit_signal("platform_changed", target_platform)
	animation_player.play("stand")
	state = AIMING
	# Should we rotate? Count platforms on the right and above.
	check_side()
	set_scale(Vector2(side, 1))
	staff.set_scale(Vector2(side, 1))

func cmp(a, b):
	return a[0] > b[0]

func get_next_platform():
	if target_platform == null: return
	
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

func my_interpolate(src, dst, alpha):
	var alpha1 = sqrt(1-alpha*alpha)
	var alpha2 = 1-sqrt(1-(1-alpha)*(1-alpha))
	return Vector2(src.x * alpha1 + dst.x * (1-alpha1), src.y * alpha2 + dst.y * (1-alpha2))

func _process(delta):
	camera.set_global_pos(Vector2(camera.get_global_pos().x, get_global_pos().y))
	gameTime += delta
	
	var player_y = -get_global_pos().y
	#print(player_y)
	
	var steps = [[-3000, 0], [-500, 0], [2500, 10], [4500, 20], [8500, 30], [15000, 40], [1000000, 40]]
	var rotation_amplitude = arr_interpolate(steps, player_y)
	var rotation_period = 3
	
	rot_base = sin(gameTime / rotation_period * 3.1415 * 2)
	var rot = rot_base * rotation_amplitude
	var bgsize = background.get_item_rect().end
	camera.set_rotd(rot + 180)
	body.set_rotd(rot)
	
	
	var staff_offset = Vector2(staff_base_offset.x * side, staff_base_offset.y).rotated(body.get_rot())
	
	staff.set_rotd(rot)
	var danglings = get_tree().get_nodes_in_group("danglings")
	for d in danglings:
		d.set_rotd(rot)
	
	staff_end = staff.get_global_pos() - get_global_pos()
	
	var hand_delta = staff_ref.get_global_pos() - shoulder_ref.get_global_pos()
	var rect = staff_hand.get_item_rect()
	var rect_length = min(420, hand_delta.length())
	
	rect = Rect2(rect.size.width - rect_length, 0, rect_length, rect.size.height)
	#staff_hand.set_offset(Vector2(-94, -34))
	staff_hand.set_offset(Vector2(-170, -34) + Vector2(rect.pos.x, 0))
	staff_hand.set_region(true)
	staff_hand.set_region_rect(rect)
	
	if state == AIMING || state == STAFF_ANIM:
		# animate hand
		staff_hand.set_global_pos(staff_ref.get_global_pos())
		var hand_rot = 0
		if hand_delta.length() > 100:
			hand_rot = -hand_delta.angle_to(Vector2(1, 0))
			if side == -1: hand_rot = 3.1415 - hand_rot
		staff_hand.set_rot(hand_rot)
	
	if state == AIMING:
		dziadek_sounds.play_random_sound("mumble")
		if not animation_player.is_playing():
			animation_player.play(["stand", "stand2", "stand3"][randi() % 3])

		if target_platform != null:
			set_global_pos(get_platform_target(target_platform))
		staff_angle -= staff_rps * 3.1415 * 2 * delta * side
		var staff_pos = get_global_pos() + staff_offset + Vector2(staff_circle_radius, 0).rotated(staff_angle)
		staff.set_global_pos(staff_pos)
	elif state == WAITING:
		dziadek_sounds.play_random_sound("sing")
		staff.set_global_pos(get_global_pos() + staff_offset)
	elif state == STAFF_ANIM:
		if(randf() < 0.01):
			dziadek_sounds.play_random_sound("sing")
		else:
			dziadek_sounds.play_random_sound("mumble")
		var staff_speed = 800 #800 + player_y / 10
		var vdelta = staff.get_global_pos() - staff_target
		if vdelta.length() < delta * staff_speed:
			if not is_space_pressed:
				start_jump()
			return
		var new_pos = staff.get_global_pos() + vdelta.normalized() * -staff_speed * delta
		staff.set_global_pos(new_pos)
	elif state == JUMPING:
		if not dziadek_sounds.is_active():
			dziadek_sounds.play_random_sound("jump")
		
		if not animation_player.is_playing():
			animation_player.play("jump")
		
		jump_progress += delta * jump_speed
		var jump_length = (jump_target - jump_start).length()
		if jump_progress > jump_length:
			start_waiting()
			return
		
		var staff_target_pos = jump_target + staff_offset
		staff.set_global_pos(jump_staff_start.linear_interpolate(staff_target_pos, jump_progress / jump_length))
		
		set_global_pos(my_interpolate(jump_start, jump_target, jump_progress / jump_length))
	elif state == DEATH:
		var pos = get_global_pos()	
		if(pos.y > - 3000 ):
			dziadek_sounds.play_random_sound("fall short")
		else: 
			dziadek_sounds.play_random_sound("fall long")
		if(pos.y > 500 and not get_node("../Camera2D/blackout_animation").is_playing()):
			get_node("../Camera2D/blackout_animation").play("blackout")
		falling_speed += delta * 50
		if pos.y > 2900:
			print("go to menu")
			get_tree().change_scene_to(menu_scene)
			return
		pos.y += falling_speed
		if death_jump:
			pos.x += side * 20
		set_global_pos(pos)
		
		var staff_pos = staff.get_pos()
		staff_pos.y += 40 * delta;
		staff.set_pos(staff_pos)
		
		if not animation_player.is_playing():
			animation_player.play("falling")

var falling_speed = -20
var death_jump

var jump_target
var jump_start
var jump_progress
var jump_staff_start

func get_platform_target(platform):
	var me_delta = Vector2(40, -510)
	#if side == -1: me_delta = 130
	var platform_width = platform.get_item_rect().size.width / 2
	var platform_pos = platform.get_global_pos() + platform.get_item_rect().pos
	return platform_pos + Vector2(platform_width / 2, 0) + me_delta
	
func start_jump():
	jump_progress = 0
	jump_start = get_global_pos()
	jump_staff_start = staff.get_global_pos()
	jump_target = get_platform_target(target_platform)
	animation_player.play("jump")
	state = JUMPING
	
func do_action():
	# AIMING -> STAFF_ANIM
	var STAFF_HEIGHT = 800
	print("do action ", staff.get_global_pos() + Vector2(0, STAFF_HEIGHT))
	var current_platform = target_platform
	target_platform = find_platform_at(get_global_pos() + staff_end)
	if(target_platform == null or current_platform == null or target_platform == current_platform):
		dziadek_sounds.play_random_sound("curse")
	
	
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
		staff_target.y = target_platform.get_item_rect().pos.y * target_platform.get_scale().y + target_platform.get_global_pos().y

func die():
	print("die :( at ", get_global_pos())
	state = DEATH
	death_jump = true
	animation_player.play("slipping")

func die_base():
	state = DEATH
	death_jump = false
	falling_speed = 20

func _input(event):
	if event.type == InputEvent.KEY and event.scancode == KEY_Q:
		var next_platform = get_next_platform()
		if next_platform == null: return
		target_platform = next_platform
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
	
# new swing mech

	