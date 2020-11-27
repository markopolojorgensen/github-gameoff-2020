extends Position2D

const spike = preload("res://spike.tscn")

var enemy = spike.instance()

func _ready():
	add_child(enemy)
	
func respawn(room_name):
	if room_name == get_parent().name and enemy.get_node("rigid_body_2d").mode == RigidBody2D.MODE_RIGID:
		enemy = spike.instance()
		_ready()
