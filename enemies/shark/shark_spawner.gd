extends Position2D

const shark = preload("res://enemies/shark/rock_throwing_shark.tscn")

var enemy = shark.instance()

func _ready():
	add_child(enemy)

	
func respawn(room_name):
	if room_name == get_parent().name and not enemy:
		_ready()

