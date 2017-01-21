extends Node2D
var zooming = false
var countdown = 0

func _ready():
	get_node("Buttons/play_button").connect("pressed",self,"_on_play_pressed")
	get_node("Buttons/exit_button").connect("pressed",self,"_on_exit_pressed")
	set_process(true)
	set_process_input(true)

func _on_play_pressed():
	get_node("background").blink()
	
func _on_exit_pressed():
	get_tree().quit()

var scene = preload("res://level1.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.scancode == KEY_SPACE:
		get_node("background").blink()

func _process(delta):
	if not zooming:
		if get_node("background").start_zoom:
			start_animation()
	else:
		countdown += delta
		if countdown > 1.5:
			get_tree().change_scene_to(scene);

func start_animation():
	get_node("AnimationPlayer").play("zoom")
	zooming = true
