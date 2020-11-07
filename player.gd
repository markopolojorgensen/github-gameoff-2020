extends RigidBody2D

const movement_impulse = 300
const movement_slowdown_scalar = 10
const max_horizontal_speed = 120

const initial_jump_impulse = 120
const continued_rising_jump_impulse = 10
const continued_falling_jump_impulse = 50

var jump_button_pushed = false

func _ready():
	# for gravity well shenanigans
	global.camera_follow = self

func _process(_delta):
	var horizontal_speed = abs(linear_velocity.x)
	var speed_weight = clamp(horizontal_speed, 0, 100) / 100.0
	$animated_sprite.frames.set_animation_speed("run", lerp(6, 18, speed_weight))
	
	var intended_direction = global.get_intended_direction()
	if intended_direction.x < -0.5:
		$animated_sprite.flip_h = true
	elif intended_direction.x > 0.5:
		$animated_sprite.flip_h = false
	
	if horizontal_speed > 5 or intended_direction.length() > 0.5:
		$animated_sprite.play("run")
	else:
		$animated_sprite.play("idle")
	
	$lin_vel.text = "%.2f" % linear_velocity.length()

func _physics_process(delta):
	# movement
	var intended_direction = global.get_intended_direction()
	
	if abs(intended_direction.x) > 0.1:
		# player wants to accelerate, so do so
		var horizontal_intended_direction = Vector2(intended_direction)
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
	
	# jumping stuff
	var wants_to_jump = Input.is_action_pressed("jump")
	var rising = linear_velocity.y < 0
	var jumped = not $jump_cooldown.is_stopped()
	var on_the_ground = $ground_detector_left.is_colliding() or $ground_detector_right.is_colliding()
	
	$wants_to_jump.text = str(wants_to_jump)
	
	# start jump?
	if wants_to_jump and not jumped and on_the_ground:
		# don't apply massive impulse every frame, use cooldown:
		jump_button_pushed = true
		$jump_cooldown.start()
		apply_central_impulse(Vector2.UP * initial_jump_impulse)
	elif on_the_ground:
		pass # TODO WHEREWASI
	
	if wants_to_jump and rising:
		# keep rising
		apply_central_impulse(Vector2.UP * continued_rising_jump_impulse * delta)
	elif wants_to_jump and not rising:
		# fall slowly
		apply_central_impulse(Vector2.UP * continued_falling_jump_impulse * delta)
	
	if not wants_to_jump and rising and not on_the_ground and linear_velocity.y < 0:
		# stop rising
		apply_central_impulse(-1 * Vector2.DOWN * linear_velocity.y)
	
	$is_rising.text = str(rising)

func accepts_gravity_well():
	return $gravity_well_cooldown.is_stopped()
