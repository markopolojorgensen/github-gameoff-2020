extends Position2D

const crawling_rocks = preload("res://crawling_rocks.tscn")
var total_rocks = clamp(global.yeet_count, 1, 50)

func _ready():
	pass

func _on_timer_timeout():
	if total_rocks > 0:
		var enemy = crawling_rocks.instance()
		enemy.starting_direction = [Vector2.RIGHT, Vector2.LEFT][randi() % 2]
		get_parent().get_node("rock_spawner").add_child(enemy)
		
		total_rocks -= 1
