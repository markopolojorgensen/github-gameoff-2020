extends CanvasLayer

# go straight to gameplay
export(bool) var skip_menu = false

func _ready():
	global.main_menu = self
	
	for menu_item in $control/menu_items.get_children():
		menu_item.connect("picked", self, "option_picked")
	
	if skip_menu:
		start_game()
	else:
		$control.show()
		get_tree().paused = true

func option_picked(option):
	match option:
		"continue":
			# TODO: savegames? actually continue?
			start_game()
		"new_game":
			start_game()
		"quit":
			get_tree().quit()
		"help":
			$control.get_node("high_score_menu/control").hide()
			$control.get_node("help_menu/control").visible = !$control.get_node("help_menu/control").visible
		"highscores":
			$control.get_node("help_menu/control").hide()
			$control.get_node("high_score_menu/control").visible = !$control.get_node("high_score_menu/control").visible
		_:
			print("mystery menu option: %s" % option)

func start_game():
	global.level_manager.load_level()
	get_tree().paused = false
	$control.hide()
	hide_submenus()

func hide_submenus():
	$control.get_node("help_menu/control").hide()
	$control.get_node("high_score_menu/control").hide()

func is_visible():
	return $control.visible
