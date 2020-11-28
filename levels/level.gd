extends Node2D

export (float) var end_time

var pause_menu = preload("res://menu/pause_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("pause_game"):
		add_child(pause_menu.instance())
		
	if event.is_action_pressed("restart_room"):
		global.current_room.respawn_player_in_last_room(global.player)
		
