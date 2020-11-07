extends Node


func _ready():
	OS.window_size = Vector2(768, 432)
	if OS.get_name() == "X11":
		OS.window_position -= OS.window_size * 1/3
	else:
		OS.window_position = OS.window_size * 1/2

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()





