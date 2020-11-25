extends Position2D

const shark = preload("res://enemies/shark/rock_throwing_shark.tscn")

var enemy = shark.instance()

func _ready():
	add_child(enemy)

	
func respawn():
	if not enemy:
		_ready()

