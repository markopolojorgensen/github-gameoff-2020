extends Node

var camera_follow
var camera

var world
var player
var current_room

var gravity_well_mode_active = false
var gravity_wells : Array = []

var nugget_count = 0

var level_manager

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



