extends CanvasLayer

# go straight to gameplay
export(bool) var skip_menu = false

func _ready():
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
		_:
			print("mystery menu option: %s" % option)

func start_game():
	global.level_manager.load_level()
	get_tree().paused = false
	$control.hide()
