extends Node2D

# this should be the same as in the level_manager script
export(int, "level 1", "level 2", "level 3", "level 4", "level 5", "ideas level", "level_select") var level_to_load
export(String) var level_name = "Chapter 1"

func _ready():
	$label.text = level_name
	update_visibility()

func update_visibility():
	if global.level_manager.max_level_index >= (level_to_load):
		show()
		$trigger/collision_shape_2d.disabled = false
	else:
		hide()
		$trigger/collision_shape_2d.disabled = true

func _on_trigger_body_entered(_body):
	if visible:
		global.level_manager.current_level_index = level_to_load
		global.level_manager.load_level()





