extends Node2D
export var number_of_wells = 0

func _ready():
	assert($room_start_area_2d.get_collision_mask_bit(1), "Room %s: start area2d cannot collide with player!" % name)
	assert($death_plane.get_collision_mask_bit(1), "Room %s: Death plane cannot collide with player!" % name)

func _on_room_start_area_2d_body_entered(body):
	# TODO: change camera shenaigans
	# TODO: update number of available wells
	global.current_room = name


func _on_death_plane_body_entered(body):
	print("I just died")
	print(name)
