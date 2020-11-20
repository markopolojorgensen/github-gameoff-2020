extends Node2D

var shake = 2
var delta_amount = 0
var shake_speed = 25

var mode = "still"

func _process(delta):
	if mode == "shake":
		position.x = position.x + delta * shake * shake_speed
		delta_amount = delta_amount + delta * shake_speed
		if (delta_amount > 1):
			shake = shake * -1
			delta_amount = 0


func _on_player_detection_body_entered(body):
	if "is_player" in body:
		mode = "shake"
		print("SHAKEN")


func _on_player_detection_body_exited(body):
	if "is_player" in body:
		if abs(body.global_position.x - global_position.x) > 32:
			mode = "still"
			
		else:
			print("will this actuall workt?")
			$rigid_body_2d.set_deferred("mode", RigidBody2D.MODE_RIGID)


func _on_rigid_body_2d_body_entered(body):
	pass # Replace with function body.
