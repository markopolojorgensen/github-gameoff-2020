extends Node2D
export var number_of_wells = 0
const player_scene = preload("res://player.tscn")

func _ready():
	assert($room_start_area_2d.get_collision_mask_bit(1), "Room %s: start area2d cannot collide with player!" % name)
	assert($death_plane.get_collision_mask_bit(1), "Room %s: Death plane cannot collide with player!" % name)
	assert($spawn_point, "Room %s: No spawn point is set")

func _on_room_start_area_2d_body_entered(body):
	# TODO: change camera shenaigans
	# TODO: update number of available wells
	print("New Room: ", name)
	global.current_room = name


func _on_death_plane_body_entered(body):
	print("I just died in ", name)
	body.queue_free()
	var player = player_scene.instance()
	player.global_position = $spawn_point.global_position
	global.world.call_deferred("add_child", player)
