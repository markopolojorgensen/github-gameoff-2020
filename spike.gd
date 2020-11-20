extends Node2D

var shake = 2
var delta_amount = 0
const shake_speed = 25
const drop_speed = 200

var shaking = false

func _process(delta):
	if shaking:
		position.x = position.x + delta * shake * shake_speed
		delta_amount = delta_amount + delta * shake_speed
		if (delta_amount > 1):
			shake = shake * -1
			delta_amount = 0


func _on_player_detection_body_entered(body):
	if "is_player" in body:
		shaking = true


func _on_player_detection_body_exited(body):
	if "is_player" in body:
		shaking = false
		if abs(body.global_position.x - global_position.x) < 32:
			$rigid_body_2d.set_deferred("mode", RigidBody2D.MODE_RIGID)
			$rigid_body_2d.call_deferred("apply_central_impulse", Vector2.DOWN * 200)


func _on_rigid_body_2d_body_entered(body):
	if "is_player" in body:
		global.current_room.respawn_player_in_last_room(body)
