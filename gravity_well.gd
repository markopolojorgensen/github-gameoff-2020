extends Node2D

const player_offset = 10
const player_scene = preload("res://player.tscn")
const thrown_rock = preload("res://enemies/shark/thrown_rock.tscn")
const random_directions = [
	Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
	Vector2.RIGHT + Vector2.UP,
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.LEFT + Vector2.UP,
	Vector2.LEFT + Vector2.DOWN,
	]
const minimum_impulse = 150
const is_gravity_well = true
const thrown_rock_radius = 100

var room_name = "???"

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
	if "is_player" in body and body.has_method("accepts_gravity_well") and body.accepts_gravity_well():
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
			
	elif "is_thrown_rock" in body:
		body.queue_free()
		var random_enemy = get_rock_launch_location()
		var returned_rock = thrown_rock.instance()
		var launch_position = random_enemy.normalized()
#		var launch_position = (random_enemy - body.global_position).normalized()
		$ding.play()
		returned_rock.global_position = global_position + launch_position * (player_offset +5 )
		returned_rock.custom_force = launch_position * minimum_impulse
		global.world.call_deferred("add_child", returned_rock)
		

func get_rock_launch_location():
	var within_range = get_enemies_within_range()
#	within_range += get_wells_within_range()
	if within_range.size() >= 1:
		return within_range[randi() % within_range.size()].global_position - global_position
	else:
		return random_directions[randi() % 8]
	
func get_enemies_within_range():
	var within_range = []
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("exists") and enemy.exists():
			var dist = get_global_transform().origin.distance_to( enemy.get_global_transform().origin )
			if dist < thrown_rock_radius:
				within_range.append(enemy.enemy)
				
	return within_range
	
func get_wells_within_range():
	var within_range = []
	var wells = get_tree().get_nodes_in_group("gravity_wells")
	for well in wells:
		var dist = get_global_transform().origin.distance_to( well.get_global_transform().origin )
		if dist< thrown_rock_radius:
			within_range.append(well)
	return within_range
		

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

func clear_room(clear_room_name):
	if room_name == clear_room_name:
		queue_free()


func show_x():
	$x_sprite.show()

func hide_x():
	$x_sprite.hide()


