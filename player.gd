extends RigidBody2D

const movement_impulse = 100

func _physics_process(delta):
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





