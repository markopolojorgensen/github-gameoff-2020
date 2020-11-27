extends Node2D


export(int, "level 1", "level 2", "level 3", "level 4", "level 5", "ideas level") var starting_level

export(NodePath) var initial_camera_path
onready var initial_camera : Camera2D = get_node(initial_camera_path)

const level_scenes = [
	preload("res://levels/01/level_01.tscn"),
	preload("res://levels/02/level_02.tscn"),
	preload("res://levels/03/level_03.tscn"),
	preload("res://levels/04/level_04.tscn"),
	preload("res://levels/05/level_05.tscn"),
	preload("res://levels/ideas/level_of_ideas.tscn"),
]

var current_level_index
var current_level
var plunger_plunged = false

const player_scene = preload("res://player.tscn")

func _ready():
	global.level_manager = self
	current_level_index = starting_level
	# call_deferred("load_level")

func load_level():
	if global.player:
		global.player.queue_free()
	
	if current_level:
		current_level.queue_free()
	
	plunger_plunged = false
	
	current_level = level_scenes[current_level_index].instance()
	add_child(current_level)
	
	global.player = player_scene.instance()
	get_parent().add_child(global.player)
	
	initial_camera.current = true
	global.camera = initial_camera
	initial_camera.global_position = global.player.global_position
	$end_timer.stop()
	$blip_timer.stop()
	$end_timer.wait_time = current_level.end_time
	global.end_timer = $end_timer
	$blip_timer.wait_time = $end_timer.wait_time - 7

func ship_entered():
	if plunger_plunged:
		$end_timer.stop()
		current_level_index += 1
		if current_level_index >= level_scenes.size():
			print("YOU WIN")
		else:
			call_deferred("load_level")

func plunger_hit():
	plunger_plunged = true
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

