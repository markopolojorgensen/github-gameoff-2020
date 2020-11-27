extends Position2D

const roy = preload("res://enemies/bat/roy.tscn")
const eight = preload("res://enemies/bat/eight.tscn")

export(String, "roy", "eight") var bat_path = "roy"
export(int) var repetitions = 3
export(int) var path_time = 4

var enemy

func _ready():
	match bat_path:
		"roy":
			enemy = roy.instance()
			
		"eight":
			enemy = eight.instance()

	enemy.repeat = repetitions
	enemy.flight_time = path_time
	add_child(enemy)

func exists():
	if enemy:
		return true
	else:
		return false
	
func respawn(room_name):
	if room_name == get_parent().name and not exists():
		_ready()

