extends RigidBody2D

const movement_impulse = 300
const movement_slowdown_scalar = 10
const max_horizontal_speed = 150
const max_air_horizontal_speed = 100

const initial_jump_impulse = 160
const continued_rising_jump_impulse = 10
const continued_falling_jump_impulse = 50

# don't preload to avoid circular dependency
var gravity_well_scene
const gravity_well_offset = 40
var gravity_well_active = false

var jump_button_pushed = false
var previously_on_the_ground = false
var is_player = true

func _ready():
	gravity_well_scene = load("res://gravity_well.tscn")
	
	# in case player was holding gw button while in a gravity well
	if Input.is_action_pressed("gravity_well_left") or Input.is_action_pressed("gravity_well_right"):
		gravity_well_active = true
	
	# for gravity well shenanigans
	global.camera_follow = self
	global.player = self

func _process(_delta):
	var horizontal_speed = abs(linear_velocity.x)
	var speed_weight = clamp(horizontal_speed, 0, 100) / 100.0
	$animated_sprite.frames.set_animation_speed("run", lerp(6, 18, speed_weight))
	
	var intended_direction
	if global.gravity_well_mode_active:
		# don't move
		intended_direction = Vector2()
	else:
		intended_direction = global.get_intended_direction()
	if intended_direction.x < -0.5:
		$animated_sprite.flip_h = true
	elif intended_direction.x > 0.5:
		$animated_sprite.flip_h = false
	
	if is_on_the_ground() and (horizontal_speed > 5 or intended_direction.length() > 0.5):
		$animated_sprite.play("run")
	elif not is_on_the_ground():
		$animated_sprite.play("flip")
	else:
		$animated_sprite.play("idle")

	
	$lin_vel.text = "%.2f" % linear_velocity.length()
	
	if gravity_well_active:
		$crosshairs.show()
		# right stick
		var gravity_well_direction = Vector2(Input.get_action_strength("gw_right") - Input.get_action_strength("gw_left"), Input.get_action_strength("gw_down") - Input.get_action_strength("gw_up"))
		if gravity_well_direction.length() < 0.1:
			if Input.is_action_pressed("gravity_well_left"):
				gravity_well_direction = Vector2(-1, -1)
			elif Input.is_action_pressed("gravity_well_right"):
				gravity_well_direction = Vector2(1, -1)
		$crosshairs.position = gravity_well_direction.normalized() * gravity_well_offset
		$gw_dir.text = str(gravity_well_direction)
	else:
		$crosshairs.hide()

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
		if is_on_the_ground():
			var overspeed = max_horizontal_speed - abs(linear_velocity.x)
			apply_central_impulse(Vector2(overspeed * sign(linear_velocity.x), 0))	
		
		else:
			var overspeed = max_air_horizontal_speed - abs(linear_velocity.x)
			apply_central_impulse(Vector2(overspeed * sign(linear_velocity.x), 0))
	
	# jumping stuff
	var wants_to_jump = Input.is_action_pressed("jump") and not global.gravity_well_mode_active
	var rising = linear_velocity.y < 0
	var jumped = not $jump_cooldown.is_stopped()
	var on_the_ground = is_on_the_ground()
	
	$wants_to_jump.text = str(wants_to_jump)
	$is_rising.text = str(rising)
	
	# start jump?
	if wants_to_jump and not jumped and on_the_ground and not jump_button_pushed:
		# don't apply massive impulse every frame, use cooldown:
		jump_button_pushed = true
		$jump_cooldown.start()
		apply_central_impulse(Vector2.UP * initial_jump_impulse)
		$jump_sfx.play()
	
	if wants_to_jump and rising:
		# keep rising
		apply_central_impulse(Vector2.UP * continued_rising_jump_impulse * delta)
	elif wants_to_jump and not rising:
		# fall slowly
		apply_central_impulse(Vector2.UP * continued_falling_jump_impulse * delta)
	
	if not wants_to_jump and rising and not on_the_ground:
		# stop rising
		apply_central_impulse(-1 * Vector2.DOWN * linear_velocity.y)
	
	# when falling, minor tunnelling can cause landing to "stutter" slightly
	# check to see if we're going to hit the ground in the next two frames or so
	$tunnel_preventer.cast_to = linear_velocity * 2 * delta
	# only care about vertical motion:
	$tunnel_preventer.cast_to.x = 0
	# only care about downward motion:
	$tunnel_preventer.cast_to.y = clamp($tunnel_preventer.cast_to.y, 0, 1000)
	$tunnel_preventer.force_raycast_update()
	if $tunnel_preventer.is_colliding():
		# slow down vertical speed to prevent tunneling
		var impulse = Vector2(linear_velocity)
		impulse.x = 0
		impulse.y *= -0.5
		apply_central_impulse(impulse)
	
	# when actually hitting the ground
	if on_the_ground and not previously_on_the_ground:
		$landing_sfx.play()
		if $animated_sprite.animation == "run":
			$animated_sprite.frame = 2
		play_random_footstep()
	
	previously_on_the_ground = on_the_ground

func _unhandled_input(event):
	if event.is_action_pressed("gravity_well_left") or event.is_action_pressed("gravity_well_right"):
		get_tree().set_input_as_handled()
		gravity_well_active = true
	elif event.is_action_released("gravity_well_left") or event.is_action_released("gravity_well_right"):
		get_tree().set_input_as_handled()
		# spawn gravity well
		var gravity_well = gravity_well_scene.instance()
		gravity_well.global_position = $crosshairs.global_position
		get_parent().add_child(gravity_well)
		global.gravity_wells.push_back(gravity_well)
		if global.gravity_wells.size() > 3:
			global.gravity_wells.pop_front().queue_free()
		gravity_well_active = false
	elif event.is_action_released("jump"):
		get_tree().set_input_as_handled()
		jump_button_pushed = false

func accepts_gravity_well():
	return $gravity_well_cooldown.is_stopped()

func is_on_the_ground():
	return $ground_detector_left.is_colliding() or $ground_detector_right.is_colliding()

func _on_animated_sprite_frame_changed():
	if $animated_sprite.animation == "run" and is_on_the_ground():
		var frame = $animated_sprite.frame
		if frame == 2 or frame == 7:
			play_random_footstep()

func play_random_footstep():
	$footsteps_sfx.get_child(randi() % $footsteps_sfx.get_child_count()).play()










