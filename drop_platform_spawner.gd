extends Position2D

const platform = preload("res://drop_platform.tscn")
var drop_platform

func _ready():
	drop_platform = platform.instance()	
	add_child(drop_platform)

	
func respawn(room_name):
	if room_name == get_parent().name and drop_platform.dropped:
		_ready()
