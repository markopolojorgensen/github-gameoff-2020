extends Node

var camera_follow
var camera

var world
var player
var current_room
var player_hud
var end_timer

var gravity_well_mode_active = false

var current_room_nugget_count = 0
var total_nugget_count = 0

var level_manager
var music_manager
var main_menu

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


func convert_seconds_to_str(t):
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	var miliseconds = int(t * 1000) % 1000

	var time = ("%02d" % minutes) + (":%02d" % seconds) + (".%03d" % miliseconds)
	return time

