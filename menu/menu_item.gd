extends Control

signal picked(option)

export(String) var menu_option = "continue"
export(bool) var initial_focus = false

func _ready():
	if initial_focus:
		grab_focus()
	else:
		$nugget.hide()

func _on_menu_item_focus_entered():
	$nugget.show()

func _on_menu_item_focus_exited():
	$nugget.hide()

func _gui_input(event):
	if event.is_action_pressed("ui_accept"):
		accept_event()
		emit_signal("picked", menu_option)
