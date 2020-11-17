extends Node2D

const player_offset = 10
const player_scene = preload("res://player.tscn")

const minimum_impulse = 150

func _ready():
	$player_in_well/animated_sprite.play()
	$x_sprite.hide()

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

func _on_area_2d_body_entered(body):
	if body.has_method("accepts_gravity_well") and body.accepts_gravity_well():
		$player_in_well.show()
		$player_in_well.global_position = body.global_position
		$player_in_well/animated_sprite.flip_h = body.get_node("animated_sprite").flip_h
		global.camera_follow = $player_in_well
		body.queue_free()
		$hum/tween.interpolate_property($hum, "volume_db", -60, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$hum/tween.start()
		$hum.play()
		$grab.play()
		if not global.gravity_well_mode_active:
			Engine.time_scale = 0.5

func is_player_in_well():
	return $player_in_well.visible

func _unhandled_input(event):
	if event.is_action_pressed("jump") and is_player_in_well() and not global.gravity_well_mode_active:
		get_tree().set_input_as_handled()
		var player = player_scene.instance()
		var destination = global.get_intended_direction().normalized() * player_offset
		player.global_position = global_position + destination
		player.jump_button_pushed = true
		global.world.add_child(player)
		player.apply_central_impulse(destination.normalized() * minimum_impulse)
		$player_in_well.hide()
		$hum.stop()
		$hum.volume_db = -60
		$ding.play()
		if not global.gravity_well_mode_active:
			Engine.time_scale = 1

func show_x():
	$x_sprite.show()

func hide_x():
	$x_sprite.hide()


