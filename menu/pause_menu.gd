extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	
	$control/panel_container/v_box_container/continue_container/menu_item.connect("picked", self, "option_picked")
	$control/panel_container/v_box_container/restart_room_container/menu_item.connect("picked", self, "option_picked")
	$control/panel_container/v_box_container/restart_level_container/menu_item.connect("picked", self, "option_picked")
	$control/panel_container/v_box_container/control_help_container/menu_item.connect("picked", self, "option_picked")
	$control/panel_container/v_box_container/exit_to_menu/menu_item.connect("picked", self, "option_picked")
	$control/panel_container/v_box_container/quit_to_windows/menu_item.connect("picked", self, "option_picked")

func option_picked(option):
	match option:
		"continue":
			continue_game()
		"restart_room":
			global.current_room.respawn_player_in_last_room(global.player)
			continue_game()
		"restart_level":
			global.level_manager.load_level()
			continue_game()
		"to_main_menu":
			get_tree().change_scene("res://game.tscn")
		"controls":
			print("test")
			$help_menu.get_node("control").visible = !$help_menu.get_node("control").visible
		"quit":
			get_tree().quit()
		_:
			print("mystery menu option: %s" % option)
			

func continue_game():
	get_tree().paused = false
	queue_free()
