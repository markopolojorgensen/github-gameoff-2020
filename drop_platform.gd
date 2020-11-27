extends Node2D

var dropped = false
const drop_speed = 100

var shaking = false
var shake = 2
var delta_amount = 0
const shake_speed = 25

func _on_drop_timer_timeout():
	if shaking:
		shaking = false
		$rigid_body_2d.mode = RigidBody2D.MODE_RIGID
		$rigid_body_2d.apply_central_impulse(Vector2.DOWN * drop_speed)
		
	else:
		$drop_timer.start()
		shaking = true
	
func _process(delta):
	if shaking:
		position.x = position.x + delta * shake * shake_speed
		delta_amount = delta_amount + delta * shake_speed
		if (delta_amount > 1):
			shake = shake * -1
			delta_amount = 0

func _on_area_2d_body_entered(body):
	if "is_player" in body:
		$drop_timer.start()
		dropped = true
