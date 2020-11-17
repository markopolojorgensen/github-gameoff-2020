extends Node2D

const gravity_well_scene = preload("res://gravity_well.tscn")

export(NodePath) var world_camera_path
onready var world_camera : Camera2D = get_node(world_camera_path)

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
			world_camera.global_position = $camera.get_camera_screen_center()
			world_camera.current = true
			$vignette_layer/vignette.hide()
			$active_hum.stop()
			global.gravity_well_mode_active = false
			if highlighted_gravity_well:
				highlighted_gravity_well.hide_x()
				highlighted_gravity_well = null
		else:
			# not active, enter gravity well placement mode!
			active = true
			Engine.time_scale = 1.0 / activated_time_factor
			global.gravity_well_mode_active = true
			show()
			global_position = world_camera.get_camera_screen_center()
			world_camera.current = false
			$camera.current = true
			$vignette_layer/vignette.show()
			$active_hum.play()
	
	
	if active and event.is_action_pressed("place_gravity_well"):
		get_tree().set_input_as_handled()
		
		if highlighted_gravity_well:
			# destroy old gravity well
			highlighted_gravity_well.queue_free()
			highlighted_gravity_well = null
		else:
			# create new gravity well
			var gravity_well = gravity_well_scene.instance()
			gravity_well.global_position = global_position
			get_parent().add_child(gravity_well)

func _process(delta):
	if not active:
		return
	
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
	highlighted_gravity_well.show_x()

func _on_well_detector_area_exited(area):
	var gravity_well = area.get_parent()
	if highlighted_gravity_well == gravity_well:
		highlighted_gravity_well.hide_x()
		highlighted_gravity_well = null















