extends Node2D

func lights_off():
	var light_off_0 = preload("res://sprites/world/ligth_off_0.png")
	var light_off_1 = preload("res://sprites/world/ligth_off_1.png")
	var light_off_2 = preload("res://sprites/world/ligth_off_2.png")
	var light_off_3 = preload("res://sprites/world/ligth_off_3.png")
	var light_off_4 = preload("res://sprites/world/ligth_off_4.png")
	
	get_node("background_0").set_texture(light_off_0)
	get_node("background_1").set_texture(light_off_1)
	get_node("background_2").set_texture(light_off_2)
	get_node("background_3").set_texture(light_off_3)
	get_node("background_4").set_texture(light_off_4)
	
	
func lights_on():
	
	var light_on_0 = preload("res://sprites/world/ligth_on_0.png")
	var light_on_1 = preload("res://sprites/world/ligth_on_1.png")
	var light_on_2 = preload("res://sprites/world/ligth_on_2.png")
	var light_on_3 = preload("res://sprites/world/ligth_on_3.png")
	var light_on_4 = preload("res://sprites/world/ligth_on_4.png")
	
	get_node("background_0").set_texture(light_on_0)
	get_node("background_1").set_texture(light_on_1)
	get_node("background_2").set_texture(light_on_2)
	get_node("background_3").set_texture(light_on_3)
	get_node("background_4").set_texture(light_on_4)