extends Node2D

var flight_started = false
export (int) var repeat = 3
export (int) var flight_time = 4

var dead_bat = preload("res://enemies/bat/dead_bat.tscn")

func start_flight():
	if not flight_started:
		flight_started = true
		
		$flight_tween.interpolate_property($path_2d/path_follow_2d, "unit_offset", 
			0, 1, flight_time,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$flight_tween.start()

func _on_flight_tween_tween_completed(object, key):
	repeat-= 1
	flight_started = false

	if repeat > 0:
		start_flight()
	else:
		$path_2d/path_follow_2d/area_2d/animated_sprite.animation = "waking"
		

func _on_player_detection_body_entered(body):
	if "is_player" in body:
		$path_2d/path_follow_2d/area_2d/animated_sprite.play()

func _on_player_detection_body_exited(body):
	if "is_player" in body:
		if abs(body.global_position.x - global_position.x) < 32:
			$path_2d/path_follow_2d/area_2d/animated_sprite.animation = "flying"
			start_flight()

func _on_area_2d_body_entered(body):
	if "is_player" in body:
		if body.global_position.y < $path_2d/path_follow_2d/area_2d.global_position.y:
			$flight_tween.stop_all()

			var new_bat = dead_bat.instance()
			new_bat.global_position.x = $path_2d/path_follow_2d/area_2d.global_position.x
			new_bat.global_position.y = $path_2d/path_follow_2d/area_2d.global_position.y
			global.world.add_child(new_bat)
			call_deferred("queue_free")
		else:
			global.current_room.respawn_player_in_last_room(body)
