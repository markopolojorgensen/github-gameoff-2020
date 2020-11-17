extends Position2D

const crawling_rocks = preload("res://crawling_rocks.tscn")

const enemy_type = "crawling_rocks"
export(String, "left", "right", "random") var starting_direction

func _ready():
	var enemy

	match enemy_type:
		"crawling_rocks":
			enemy = crawling_rocks.instance()

	match starting_direction:
		"left":
			enemy.starting_direction = Vector2.LEFT
		"right":
			enemy.starting_direction = Vector2.RIGHT
		"random":
			randomize()
			enemy.starting_direction = [Vector2.RIGHT, Vector2.LEFT][randi() % 2]

	add_child(enemy)
