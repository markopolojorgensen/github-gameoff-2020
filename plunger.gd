extends RigidBody2D

func _on_plunger_body_entered(body):
	if "is_player" in body:
		$animated_sprite.animation = "plunging"
