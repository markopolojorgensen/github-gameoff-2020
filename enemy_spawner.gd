extends Position2D

const crawling_rocks = preload("res://crawling_rocks.tscn")

const enemy_type = "crawling_rocks"
export(String, "left", "right", "random") var starting_direction

var enemy = crawling_rocks.instance()

func _ready():
	match starting_direction:
		"left":
			enemy.starting_direction = Vector2.LEFT
		"right":
			enemy.starting_direction = Vector2.RIGHT
		"random":
			randomize()
			enemy.starting_direction = [Vector2.RIGHT, Vector2.LEFT][randi() % 2]

	add_child(enemy)

func exists():
	return enemy.rock_mode == "walking" or enemy.rock_mode == "flipped"

func respawn():
	if not exists():
		enemy = crawling_rocks.instance()
		_ready()
