extends Node2D
export var number_of_wells = 0
const player_scene = preload("res://player.tscn")
const player_death_fx_scene = preload("res://fx/player_death_fx.tscn")

func _ready():
	assert($room_start_area_2d.get_collision_mask_bit(1), "Room %s: start area2d cannot collide with player!" % name)
	assert($death_plane.get_collision_mask_bit(1), "Room %s: Death plane cannot collide with player!" % name)
	assert($spawn_point, "Room %s: No spawn point is set" % name) # used in crawling_rocks.gd
	print($tile_map.global_position)
	
func _on_room_start_area_2d_body_entered(_body):
	# TODO: change camera shenaigans
	# TODO: update number of available wells
	print("New Room: ", name)
	global.current_room = self
	
	if not global.level_manager.plunger_plunged:
		var camera : Camera2D = global.camera
		for camera_limit in $camera_limits.get_children():
			match camera_limit.name:
				"limit_left":
					camera.limit_left = camera_limit.global_position.x
				"limit_right":
					camera.limit_right = camera_limit.global_position.x
				"limit_top":
					camera.limit_top = camera_limit.global_position.y
				"limit_bottom":
					camera.limit_bottom = camera_limit.global_position.y

func respawn_player_in_last_room(body):
	# we only want the player to respawn at the spawn point, not any other enemies!
	if "is_player" in body:
		var player_death_fx = player_death_fx_scene.instance()
		add_child(player_death_fx)
		player_death_fx.global_position = body.global_position
		body.queue_free()
		var player = player_scene.instance()
		player.global_position = global.current_room.get_node("spawn_point").global_position
		global.world.call_deferred("add_child", player)
		get_tree().call_group("enemies", "respawn")

func _on_death_plane_body_entered(body):
	if "is_player" in body:
		respawn_player_in_last_room(body)
	else:
		print("Body %s: has died" % body.name)
		body.queue_free()
	# TODO: expand the death plane to enemies? and then free them when they die?
	# I'll have to ask Jorg about if godot will clear enemies or not.
