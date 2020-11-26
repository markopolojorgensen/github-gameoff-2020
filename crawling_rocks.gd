extends RigidBody2D

const movement_impulse = 300
const movement_slowdown_scalar = 10
const max_horizontal_speed = 40
const flip_rotation_speed = 250 #should be 2500, set to 250 because player doens't hop off after hitting enemy yet

const initial_jump_impulse = 100
const continued_falling_jump_impulse = 70
const is_crawling_rock = true

var current_direction = null
export(Vector2) var starting_direction

export(bool) var awake = false
var rock_mode = "walking"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$animation_player.play("sleeping")
	current_direction = starting_direction
	if starting_direction == Vector2.RIGHT:
		_handle_right_movement()
	else:
		_handle_left_movement()
	

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

func _process(delta):
	if not awake:
		return
	
	match rock_mode:
		"walking":
			_process_walking(delta)
			
		"flipping_left":
			_process_flipping_left(delta)
			
		"flipping_right":
			_process_flipping_right(delta)
			
		"kicked_left":
			_process_kicked_left(delta)
			
		"kicked_right":
			_process_kicked_right(delta)

func _process_walking(delta):
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

func _process_flipping_right(delta):
	$animated_sprite.rotation_degrees += delta * flip_rotation_speed
	if $animated_sprite.rotation_degrees >= 180:
		$animated_sprite.rotation_degrees = 180
		rock_mode = "flipped"

func _process_flipping_left(delta):
	$animated_sprite.rotation_degrees -= delta * flip_rotation_speed
	if $animated_sprite.rotation_degrees <= -180:
		$animated_sprite.rotation_degrees = -180
		rock_mode = "flipped"

func _on_walking_rocks_body_entered(body):
	if "is_player" in body:
		match rock_mode:
			"walking":
				walking_player_collision(body)
				
			"flipped":
				flipped_player_collision(body)
				
	if "is_crawling_rock" in body:
		if "kicked" in body.rock_mode:
			initialize_kick(body)
			
	if "is_thrown_rock" in body:
		if "flipped" in rock_mode:
			initialize_kick(body)
		else:
			rock_mode = "flipping_left"
		body.queue_free()
		

func walking_player_collision(body):
	# TODO: maybe also velocity?
	if body.global_position.y < global_position.y:
		jumped_on(body)
	else:
		hit_player(body)
			
func jumped_on(body):
	if body.global_position.x < global_position.x:
		rock_mode = "flipping_right"
	else:
		rock_mode = "flipping_left"
	body.get_node("jump_cooldown").start()

func hit_player(body):
	global.current_room.respawn_player_in_last_room(body)
	
func flipped_player_collision(body):
	if Input.is_action_pressed("player_hold_item"):
		rock_mode = "picked_up"
		print("picked up")
		
	else:
		print("yeeted")
		initialize_kick(body)


func initialize_kick(body):
	$kick_jump_timer.start()
	set_collision_mask_bit(0, false)
	if body.global_position.x < global_position.x:
		rock_mode = "kicked_right"
	else:
		rock_mode = "kicked_left"

func _process_kicked_left(delta):
	handle_vertical_kick(delta)
	apply_central_impulse(Vector2.LEFT * delta * movement_impulse)
		
func _process_kicked_right(delta):
	handle_vertical_kick(delta)
	apply_central_impulse(Vector2.RIGHT * delta * movement_impulse)

func handle_vertical_kick(delta):
	$animated_sprite.rotation_degrees += delta * flip_rotation_speed * 100
	var rising = linear_velocity.y < 0
	if not $kick_jump_timer.is_stopped():
		apply_central_impulse(Vector2.UP * initial_jump_impulse)
	else:
		if rising:
			apply_central_impulse(-1 * Vector2.DOWN * linear_velocity.y)
		else:
			apply_central_impulse(Vector2.DOWN * continued_falling_jump_impulse * delta)

func _on_player_detector_body_entered(body):
	if "is_player" in body and body.is_player and not awake:
		$animation_player.play("wake_up")
		awake = true

