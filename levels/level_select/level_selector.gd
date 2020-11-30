extends Node2D

# this should be the same as in the level_manager script
export(int, "level 1", "level 2", "level 3", "level 4", "level 5", "ideas level", "level_select") var level_to_load
export(String) var level_name = "Chapter 1"

func _ready():
	$label.text = level_name

func _on_trigger_body_entered(_body):
	global.level_manager.current_level_index = level_to_load
	global.level_manager.load_level()





