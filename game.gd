extends Node


func _ready():
	OS.window_size = Vector2(768, 432)
	OS.window_position -= OS.window_size * 1/3

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

