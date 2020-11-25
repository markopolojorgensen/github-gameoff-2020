extends Node2D


export(int, "level 1", "level 2", "level 3", "ideas level") var starting_level

export(NodePath) var initial_camera_path
onready var initial_camera : Camera2D = get_node(initial_camera_path)

const level_scenes = [
	preload("res://levels/01/level_01.tscn"),
	preload("res://levels/02/level_02.tscn"),
	preload("res://levels/03/level_03.tscn"),
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

func ship_entered():
	if plunger_plunged:
		current_level_index += 1
		if current_level_index >= level_scenes.size():
			print("YOU WIN")
		else:
			call_deferred("load_level")

func plunger_hit():
	plunger_plunged = true










