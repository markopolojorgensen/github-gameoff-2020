extends Node2D
export var number_of_wells = 0
const player_scene = preload("res://player.tscn")
const player_death_fx_scene = preload("res://fx/player_death_fx.tscn")

func _ready():
	assert($room_start_area_2d.get_collision_mask_bit(1), "Room %s: start area2d cannot collide with player!" % name)
	assert($death_plane.get_collision_mask_bit(1), "Room %s: Death plane cannot collide with player!" % name)
	assert(has_node("spawn_point_there"), "Room %s: No spawn_point_there is set" % name)
	assert(has_node("spawn_point_back"), "Room %s: No spawn_point_back is set" % name)
	
	if not is_connected("tree_exiting", self, "_on_generic_room_tree_exiting"):
		print("whoops, tree_exiting signal wasn't hooked up for %s!" % name)
		connect("tree_exiting", self, "_on_generic_room_tree_exiting")

	# minor hack to get the gravity_well_tracker to not explode if the level is restarted on the fly
	global.current_room = self
	gravity_well_tracker.register_room(name)

	if has_node("parallax_background"):
		if "scroll_base_offset" in $parallax_background:
			$parallax_background.scroll_base_offset = global_position
		else:
			for layer in $parallax_background.get_children():
				if "scroll_base_offset" in layer:
					layer.scroll_base_offset = global_position
				else:
					print("whoops, %s has no parallax background?" % name)

func _on_room_start_area_2d_body_entered(_body):
	# TODO: change camera shenaigans
	# TODO: update number of available wells
	print("New Room: ", name)
	global.current_room = self
	gravity_well_tracker.update()
	get_tree().call_group("rooms", "update_arrows")

	if not global.level_manager.plunger_plunged:
		if has_node("camera_limits"):
			get_tree().call_group("camera_limits", "adjust_limits",
				$camera_limits/limit_left.global_position.x,
				$camera_limits/limit_right.global_position.x,
				$camera_limits/limit_top.global_position.y,
				$camera_limits/limit_bottom.global_position.y)
		else:
			print("%s has no camera limits!" % name)

func kill_player(body):
	var player_death_fx = player_death_fx_scene.instance()
	add_child(player_death_fx)
	player_death_fx.global_position = body.global_position
	body.queue_free()

func respawn_player_in_last_room(body):
	if "is_player" in body:
		kill_player(body)
		var player = player_scene.instance()

		if global.level_manager.plunger_plunged:
			player.global_position = global.current_room.get_node("spawn_point_back").global_position
			get_tree().call_group("sonic_camera", "smooth_time_start")
		else:
			player.global_position = global.current_room.get_node("spawn_point_there").global_position
			get_tree().call_group("enemies", "respawn", global.current_room.name)
			get_tree().call_group("gravity_wells", "clear_room", global.current_room.name)
		global.world.call_deferred("add_child", player)
		
		
func _on_death_plane_body_entered(body):
	if "is_player" in body:
		respawn_player_in_last_room(body)
	else:
		print("Body %s: has died" % body.name)
		body.queue_free()
	# TODO: expand the death plane to enemies? and then free them when they die?

func add_nugget():
	global.current_room_nugget_count += 1
	global.end_timer.wait_time += .5


func _on_generic_room_tree_exiting():
	# global.current_room.name gets weird during loading, but this _should_ work.
	print("Clearing room: ", name)
	get_tree().call_group("gravity_wells", "clear_room", name)

func update_arrows():
	if global.current_room == self:
		for arrow in $arrows.get_children():
			arrow.show()
	else:
		for arrow in $arrows.get_children():
			arrow.hide()



