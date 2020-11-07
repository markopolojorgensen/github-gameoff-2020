extends Node2D

const player_offset = 10
const player_scene = preload("res://player.tscn")

const minimum_impulse = 150

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$sprite.rotation_degrees += delta * 50
	$player_in_well.rotation_degrees += delta * 100
	
	if is_player_in_well():
		var intended_direction = global.get_intended_direction()
		if intended_direction.length() > 0.5:
			# sprite should lean in direction of exit
			var destination = intended_direction.normalized() * player_offset
			$player_in_well.position = $player_in_well.position.linear_interpolate(destination, 3 * delta)
		else:
			# no intended direction, lerp back to center of well
			$player_in_well.position = $player_in_well.position.linear_interpolate(Vector2(), delta)
		
		# update camera position

func _on_area_2d_body_entered(body):
	if body.name == "player" and body.accepts_gravity_well():
		$player_in_well.show()
		$player_in_well.global_position = body.global_position
		$player_in_well/animated_sprite.flip_h = body.get_node("animated_sprite").flip_h
		global.camera_follow = $player_in_well
		body.queue_free()
		$hum/tween.interpolate_property($hum, "volume_db", -60, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$hum/tween.start()
		$hum.play()
		$grab.play()

func is_player_in_well():
	return $player_in_well.visible

func _unhandled_input(event):
	if event.is_action_pressed("jump") and is_player_in_well():
		get_tree().set_input_as_handled()
		var player = player_scene.instance()
		player.global_position = $player_in_well.global_position
		get_parent().add_child(player)
		player.apply_central_impulse($player_in_well.position.normalized() * minimum_impulse)
		$player_in_well.hide()
		$hum.stop()
		$hum.volume_db = -60





