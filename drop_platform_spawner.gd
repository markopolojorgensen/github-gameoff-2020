extends Position2D

const platform = preload("res://drop_platform.tscn")
var drop_platform

func _ready():
	drop_platform = platform.instance()	
	add_child(drop_platform)

	
func respawn():
	if drop_platform.dropped:
		_ready()
