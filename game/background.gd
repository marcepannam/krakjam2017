extends Node2D
var blink_timer = -1
var lights_on = true
var start_zoom = false

var light_on_0 = preload("res://sprites/world/ligth_on_0.tex")
var light_on_1 = preload("res://sprites/world/ligth_on_1.tex")
var light_on_2 = preload("res://sprites/world/ligth_on_2.tex")
var light_on_3 = preload("res://sprites/world/ligth_on_3.tex")
var light_on_4 = preload("res://sprites/world/ligth_on_4.tex")

var light_off_0 = preload("res://sprites/world/ligth_off_0.tex")
var light_off_1 = preload("res://sprites/world/ligth_off_1.tex")
var light_off_2 = preload("res://sprites/world/ligth_off_2.tex")
var light_off_3 = preload("res://sprites/world/ligth_off_3.tex")
var light_off_4 = preload("res://sprites/world/ligth_off_4.tex")

func _ready():
    set_process(true)

func _process(delta):
	if(blink_timer > 0):
		blink_timer -= delta * 50
		if(blink_timer <= 0):
			lights_off()
			get_node("../menu_sounds").play("menu - lanternpop")
			start_zoom = true
		elif((randi() % 600) < blink_timer):
			if(lights_on):
				if(not get_node("../menu_sounds").is_active()):
					get_node("../menu_sounds").play("menu - lanternpop")
				lights_off()
			else:
				lights_on()

func blink():
	if(blink_timer < 0):
		blink_timer = 100
		lights_off()
		get_node("../menu_sounds").play("menu - lanternpop")
	
	

func lights_off():
	lights_on = false
	get_node("background_0").set_texture(light_off_0)
	get_node("background_1").set_texture(light_off_1)
	get_node("background_2").set_texture(light_off_2)
	get_node("background_3").set_texture(light_off_3)
	get_node("background_4").set_texture(light_off_4)
	
	
func lights_on():
	lights_on = true
	get_node("background_0").set_texture(light_on_0)
	get_node("background_1").set_texture(light_on_1)
	get_node("background_2").set_texture(light_on_2)
	get_node("background_3").set_texture(light_on_3)
	get_node("background_4").set_texture(light_on_4)