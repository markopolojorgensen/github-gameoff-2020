extends Node2D


export(int, "chapter 1", "chapter 2", "chapter 3", "chapter 4", "chapter 5", "chapter 6", "chapter 7", "epilogue", "ideas level", "level_select") var starting_level

export(NodePath) var initial_camera_path
onready var initial_camera : Camera2D = get_node(initial_camera_path)

const level_scenes = [
	preload("res://levels/01/level_01.tscn"),
	preload("res://levels/07/level_07.tscn"),	
	preload("res://levels/04/level_04.tscn"),
	preload("res://levels/03/level_03.tscn"),
	preload("res://levels/05/level_05.tscn"),
	preload("res://levels/06/level_06.tscn"),
	preload("res://levels/02/level_02.tscn"),
	preload("res://levels/epilog/epilog.tscn"),
	preload("res://levels/ideas/level_of_ideas.tscn"),
	preload("res://levels/level_select/level_select.tscn"),
]

var current_level_index
var max_level_index = 0
var current_level
var plunger_plunged = false
var level_finished = false
var start_time
var middle_time
var end_time

# bool to prevent multiple level loading calls overlapping
var loading = false

var best_level_times = {}

const player_scene = preload("res://player.tscn")

func _ready():
	global.level_manager = self
	current_level_index = starting_level
	load_game()
	

func load_level():
	if not loading:
		loading = true
		
		global.transition.do_transition()
		yield(global.transition, "halfway")
		
		if global.player:
			global.player.queue_free()
		
		if current_level:
			current_level.queue_free()
		
		level_finished = false
		plunger_plunged = false
		global.music_manager.fade_to_calm()
		
		current_level = level_scenes[current_level_index].instance()
		call_deferred("add_child", current_level)
		
		global.current_room_nugget_count = 0
		
		global.player = player_scene.instance()
		get_parent().call_deferred("add_child", global.player)
		
		initial_camera.current = true
		global.camera = initial_camera
		# initial_camera.set_deferred("global_position", global.player.global_position)
		initial_camera.global_position = Vector2()
		$end_timer.stop()
		$blip_timer.stop()
		$end_timer.wait_time = clamp(current_level.end_time, 0.0001, 100000000)
		global.end_timer = $end_timer
		$blip_timer.wait_time = clamp($end_timer.wait_time - 7, 0.0001, 100000000)
		start_time = OS.get_ticks_msec()
		
		loading = false

func ship_entered():
	if plunger_plunged:
		level_finished = true
		$end_timer.stop()
		$blip_timer.stop()
		end_time = OS.get_ticks_msec()
		update_best_level_times(start_time, middle_time, end_time)		
		
		current_level_index += 1
		if current_level_index > max_level_index:
			max_level_index = current_level_index
		global.player_hud.show_level_complete(start_time, middle_time, end_time)
		save_game()
		
		if current_level_index >= level_scenes.size():
			print("YOU WIN")
		else:
			yield(global.player_hud, "acknowledged")
			call_deferred("load_level")
		global.total_nugget_count += global.current_room_nugget_count


func update_best_level_times(start, middle, end):
	var return_time = end-middle
	var total_time = end-start
	if current_level_index in best_level_times:
		if return_time < best_level_times[current_level_index]["return_time"]:
			best_level_times[current_level_index]["return_time"] = return_time
			
		if total_time < best_level_times[current_level_index]["total_time"]:
			best_level_times[current_level_index]["total_time"] = total_time
	else:
		best_level_times[current_level_index] = {
			"return_time": return_time,
			"total_time": total_time
		}

func plunger_hit():
	middle_time = OS.get_ticks_msec()
	plunger_plunged = true
	if global.easy_mode:
		$end_timer.start()
		$blip_timer.start()

func _on_end_timer_timeout():
	global.current_room.kill_player(global.player)
	$player_explosion_timer.start()
	$final_tone.play()

func _on_player_explosion_timer_timeout():
	load_level()


func _on_blip_timer_timeout():
	$blip_timer.wait_time = .067 * $end_timer.get_time_left() + .27
	$blip_timer.start()
	$blip_noise.play()

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)

	var save_data = {
		"max_level_index": max_level_index,
		"best_level_times": best_level_times,
		"nuggets": global.total_nugget_count,
		"yeets": global.yeet_count,
		"easy_mode": global.easy_mode
	}

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(to_json(save_data))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		max_level_index = node_data["max_level_index"]
		best_level_times = node_data["best_level_times"]
		global.total_nugget_count = node_data["nuggets"]
		global.yeet_count = node_data["yeets"]
		global.easy_mode = node_data["easy_mode"]

	save_game.close()
