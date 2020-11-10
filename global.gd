extends Node

var camera_follow

var gravity_wells : Array = []

func get_intended_direction():
	var result = Vector2()
	
	if Input.is_action_pressed("ui_left"):
		result += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		result += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		result += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		result += Vector2.DOWN
	
	return result



