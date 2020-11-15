extends Node2D

const gravity_well_scene = preload("res://gravity_well.tscn")

export(NodePath) var world_camera_path
onready var world_camera : Camera2D = get_node(world_camera_path)

var active = false
var velocity = Vector2()
const acceleration = 2000
const max_speed = 160

func _ready():
	$vignette_layer/vignette.hide()

func _unhandled_input(event):
	if event.is_action_pressed("gravity_well_mode"):
		get_tree().set_input_as_handled()
		if active:
			# deactivate
			active = false
			get_tree().paused = false
			hide()
			$camera.current = false
			world_camera.global_position = $camera.get_camera_screen_center()
			world_camera.current = true
			$vignette_layer/vignette.hide()
		else:
			# not active, enter gravity well placement mode!
			active = true
			get_tree().paused = true
			show()
			global_position = world_camera.get_camera_screen_center()
			world_camera.current = false
			$camera.current = true
			$vignette_layer/vignette.show()
	
	
	if active and event.is_action_pressed("place_gravity_well"):
		get_tree().set_input_as_handled()
		var gravity_well = gravity_well_scene.instance()
		gravity_well.global_position = global_position
		get_parent().add_child(gravity_well)

func _process(delta):
	if not active:
		return
	
	# accelerate
	var intended_direction = global.get_intended_direction()
	if intended_direction.length() > 0.05:
		velocity += intended_direction * acceleration * delta
	velocity = velocity.clamped(max_speed)
	
	# slow down
	velocity -= velocity * 10 * delta
	
	# move
	global_position += velocity * delta



