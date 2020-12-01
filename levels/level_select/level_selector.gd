extends Node2D

# this should be the same as in the level_manager script
export(int, "level 1", "level 2", "level 3", "level 4", "level 5", "level 6", "level 7", "ideas level", "level_select") var level_to_load
export(String) var level_name = "Chapter 1"

func _ready():
	$label.text = level_name
	update_visibility()
	$sprite.rotation_degrees = randi() % 360

func _process(delta):
	$sprite.rotation_degrees += delta * 50

func update_visibility():
	if global.level_manager.max_level_index >= (level_to_load):
		set_process(true)
		show()
		$trigger/collision_shape_2d.disabled = false
	else:
		set_process(false)
		hide()
		$trigger/collision_shape_2d.disabled = true

func _on_trigger_body_entered(_body):
	if visible:
		global.level_manager.current_level_index = level_to_load
		global.level_manager.load_level()





