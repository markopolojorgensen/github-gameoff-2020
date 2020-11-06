extends RigidBody2D


const movement_impulse = 300
const max_horizontal_speed = 100

const initial_jump_impulse = 120
const continued_jump_impulse = 10
var rising = false


func _process(_delta):
	var intended_direction = get_intended_direction()
	if intended_direction.x < -0.5:
		$animated_sprite.flip_h = true
	elif intended_direction.x > 0.5:
		$animated_sprite.flip_h = false
	
	if abs(linear_velocity.x) > 5 or intended_direction.length() > 0.5:
		$animated_sprite.play("run")
	else:
		$animated_sprite.play("idle")
	
	$lin_vel.text = "%.2f" % linear_velocity.length()

func _physics_process(delta):
	# movement
	var intended_direction = get_intended_direction()
	
	if abs(intended_direction.x) > 0.1:
		# player wants to accelerate, so do so
		var horizontal_intended_direction = Vector2(intended_direction)
		horizontal_intended_direction.y = 0
		apply_central_impulse(horizontal_intended_direction.normalized() * delta * movement_impulse)
	else:
		# player doesn't want to accelerate, so slow down
		var horizontal_linear_velocity = Vector2(linear_velocity)
		horizontal_linear_velocity.y = 0
		apply_central_impulse(-1 * horizontal_linear_velocity.normalized() * delta * movement_impulse)
	
	# limit maximum horizontal speed
	if abs(linear_velocity.x) > max_horizontal_speed:
		var overspeed = max_horizontal_speed - abs(linear_velocity.x)
		apply_central_impulse(Vector2(overspeed * sign(linear_velocity.x), 0))
	
	
	# jumping stuff
	var wants_to_jump = Input.is_action_pressed("ui_accept")
	$wants_to_jump.text = str(wants_to_jump)
	
	# start jump?
	if not rising and wants_to_jump and $ground_detector.is_colliding():
		rising = true
		$rise_timer.start()
		apply_central_impulse(Vector2.UP * initial_jump_impulse)
	
	# keep rising
	if rising and wants_to_jump:
		apply_central_impulse(Vector2.UP * continued_jump_impulse * delta)
	
	# stop rising
	# this applies even when we're on the ground, to control weird tilemap bouncing
	if not wants_to_jump:
		rising = false
		$rise_timer.stop()
		if linear_velocity.y < 0:
			apply_central_impulse(-1 * Vector2.DOWN * linear_velocity.y)
	
	$is_rising.text = str(rising)

func get_intended_direction():
	var result = Vector2()
	
	if Input.is_action_pressed("ui_left"):
		result += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		result += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		result += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		result += Vector2.DOWN
	
	return result

func _on_rise_timer_timeout():
	rising = false
