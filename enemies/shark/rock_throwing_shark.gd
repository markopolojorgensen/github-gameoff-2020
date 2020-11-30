extends Node2D

var old_direction = "right"
var current_direction = "right"
const movement_speed = 30
var player_in_front = false

var throw_rock = false

var rock = preload("res://enemies/shark/thrown_rock.tscn")

func _process(delta):
	if $air_detector.is_colliding() or not $edge_detector.is_colliding():
		change_direction()
	
	match current_direction:
		"right":
			global_position.x += delta * movement_speed
			if global.player:
				player_in_front = global.player.global_position.x > global_position.x
			launch_rock_check()
			
		"left":
			global_position.x -= delta * movement_speed
			if global.player:
				player_in_front = global.player.global_position.x < global_position.x
			launch_rock_check()

		"throwing":
			$animated_sprite.animation = "down"
			current_direction = "down"
			$spike_wait.start()
			

	
func change_direction():
	throw_rock = true
	
	match current_direction:
		"right":
			current_direction = "left"
			$animated_sprite.flip_h = true
			$edge_detector.cast_to.x = -15
			$edge_detector.position.x = -8
			$air_detector.position.x = -8
			
		"left":
			current_direction = "right"
			$animated_sprite.flip_h = false
			$edge_detector.cast_to.x = 15
			$edge_detector.position.x = 8
			$air_detector.position.x = 8

func launch_rock_check():
	if throw_rock && randf() > .95 && player_in_front:
		throw_rock = false
		old_direction = current_direction
		current_direction = "throwing"

func _on_rock_throwing_shark_body_entered(body):
	if "is_player" in body and $animated_sprite.animation == "spike":
		global.current_room.respawn_player_in_last_room(body)

func _on_spike_wait_timeout():
	$animated_sprite.animation = "spike"
	$restart_trawl.start()
	var deadly_ass_rock = rock.instance()
	
	deadly_ass_rock.direction = old_direction
	deadly_ass_rock.position.x = global_position.x
	deadly_ass_rock.position.y = global_position.y - 10
	
	global.world.add_child(deadly_ass_rock)
	

func _on_restart_trawl_timeout():
	$animated_sprite.animation = "trawling"
	current_direction = old_direction
	
	
