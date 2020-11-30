extends Node2D

const gravity_well_scene = preload("res://gravity_well.tscn")

# slow down time by this much when active
var activated_time_factor = 30

var active = false
var velocity = Vector2()
const acceleration = 2000
const max_speed = 160

var highlighted_gravity_well

func _ready():
	$vignette_layer/vignette.hide()
	hide()
	$sprite.play()

func _unhandled_input(event):
	if event.is_action_pressed("gravity_well_mode"):
		get_tree().set_input_as_handled()
		if active:
			# deactivate
			active = false
			Engine.time_scale = 1
			hide()
			$camera.current = false
			global.camera.global_position = $camera.get_camera_screen_center()
			global.camera.current = true
			$vignette_layer/vignette.hide()
			$active_hum.stop()
			global.music_manager.filter_fade_open()
			global.gravity_well_mode_active = false
			if highlighted_gravity_well:
				highlighted_gravity_well.hide_x()
				highlighted_gravity_well = null
		elif not global.main_menu.is_visible():
			# don't enter gravity well placement mode in the main menu
			# not active, enter gravity well placement mode!
			active = true
			Engine.time_scale = 1.0 / activated_time_factor
			global.gravity_well_mode_active = true
			show()
			global_position = global.camera.get_camera_screen_center()
			global.camera.current = false
			# don't set global.camera to be this one, we need it later!
			$camera.current = true
			$vignette_layer/vignette.show()
			$active_hum.play()
			global.music_manager.filter_fade_closed()
	
	
	if active and event.is_action_pressed("place_gravity_well"):
		get_tree().set_input_as_handled()
		
		if highlighted_gravity_well and not highlighted_gravity_well.is_player_in_well():
			# destroy old gravity well
			gravity_well_tracker.remove_well(highlighted_gravity_well)
			highlighted_gravity_well.delete()
			highlighted_gravity_well = null
			update_cursor()
		else:
			# create new gravity well
			if gravity_well_tracker.can_add_well() and $ground_detector.get_overlapping_bodies().size() <= 0:
				var gravity_well = gravity_well_scene.instance()
				gravity_well_tracker.add_well(gravity_well)
				gravity_well.global_position = global_position
				gravity_well.room_name = global.current_room.name
				get_parent().add_child(gravity_well)
				update_cursor()
			elif not gravity_well_tracker.can_add_well():
				$meepmerp.play()
				gravity_well_tracker.gravity_well_hud.shake_it_up()
			elif $ground_detector.get_overlapping_bodies().size() > 0:
				$meepmerp.play()
				$sprite/shaker.add_trauma(1)
		
		gravity_well_tracker.update()
	
	if event.is_action_pressed("clear_room_wells"):
		get_tree().set_input_as_handled()
		get_tree().call_group("gravity_wells", "clear_room", global.current_room.name)

func _process(delta):
	if not active:
		return
	
	$sprite/shaker.increment(delta)
	$sprite.position = $sprite/shaker.get_shake() * 3
	$sprite.rotation_degrees = $sprite/shaker.get_roll() * 22.5
	
	# accelerate
	var intended_direction = global.get_intended_direction()
	if intended_direction.length() > 0.05:
		velocity += intended_direction * acceleration * delta * activated_time_factor
	velocity = velocity.clamped(max_speed)
	
	# slow down
	velocity -= velocity * 10 * delta * activated_time_factor
	
	# move
	global_position += velocity * delta * activated_time_factor

func _on_well_detector_area_entered(area):
	var gravity_well = area.get_parent()
	if highlighted_gravity_well:
		highlighted_gravity_well.hide_x()
	
	highlighted_gravity_well = gravity_well
	if not highlighted_gravity_well.is_player_in_well():
		highlighted_gravity_well.show_x()

func _on_well_detector_area_exited(area):
	var gravity_well = area.get_parent()
	if highlighted_gravity_well == gravity_well:
		highlighted_gravity_well.hide_x()
		highlighted_gravity_well = null

func adjust_limits(left, right, top, bottom):
	$camera.limit_left = left
	$camera.limit_right = right
	$camera.limit_top = top
	$camera.limit_bottom = bottom

func _on_ground_detector_body_entered(_body):
	call_deferred("update_cursor")

func _on_ground_detector_body_exited(_body):
	call_deferred("update_cursor")

func update_cursor():
	if $ground_detector.get_overlapping_bodies().size() <= 0 and gravity_well_tracker.can_add_well():
		$sprite.modulate = Color(1, 1, 1, 1)
		$sprite.play("default")
	else:
		# colliding with ground or out of wells
		# either way, darken cursor
		$sprite.modulate = Color(0.5, 0.5, 0.5, 1)
		$sprite.play("borked")
		$sprite.frame = 0















