extends RigidBody2D

const movement_impulse = 300
const movement_slowdown_scalar = 10
const max_horizontal_speed = 40
var current_direction = null

const player_scene = preload("res://player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$animated_sprite.animation = "walking"
	current_direction = [Vector2.RIGHT, Vector2.LEFT][randi() % 2]
	change_direction()


func change_direction():
	if current_direction == Vector2.RIGHT:
		_handle_left_movement()
	else:
		_handle_right_movement()

func _handle_left_movement():
	current_direction = Vector2.LEFT
	$ray_cast_2d.cast_to.x = -10
	$cliff_detector.cast_to.x = -5
	$animated_sprite.flip_h = true

func _handle_right_movement():
	current_direction = Vector2.RIGHT
	$ray_cast_2d.cast_to.x = 10
	$cliff_detector.cast_to.x = 5
	$animated_sprite.flip_h = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var result = Vector2()
	result += current_direction
	if abs(result.x) > 0.1:
		# player wants to accelerate, so do so
		var horizontal_intended_direction = Vector2(result)
		horizontal_intended_direction.y = 0
		apply_central_impulse(horizontal_intended_direction.normalized() * delta * movement_impulse)
	else:
		# player doesn't want to accelerate, so slow down
		var horizontal_linear_velocity = Vector2(linear_velocity)
		horizontal_linear_velocity.y = 0
		apply_central_impulse(-1 * horizontal_linear_velocity * delta * movement_slowdown_scalar)
	
	# limit maximum horizontal speed
	if abs(linear_velocity.x) > max_horizontal_speed:
		var overspeed = max_horizontal_speed - abs(linear_velocity.x)
		apply_central_impulse(Vector2(overspeed * sign(linear_velocity.x), 0))
		
	if $ray_cast_2d.is_colliding():
		change_direction()		
	
	if not $cliff_detector.is_colliding():
		change_direction()


func _on_walking_rocks_body_entered(body):
	if "is_player" in body:
		if body.global_position.y < global_position.y:
			queue_free()
			# TODO: flip over and stop animating
			# TODO: hop after killing enemy
		else:
			body.queue_free()
			var player = player_scene.instance()
			player.global_position = global.current_room.get_node("spawn_point").global_position
			global.world.call_deferred("add_child", player)
