extends Area2D

func _on_plunger_body_entered(body):
	if "is_player" in body and not global.level_manager.plunger_plunged:
		$animated_sprite.animation = "plunging"
		$plunge.play()
		
		get_tree().call_group("plunger_listeners", "plunger_hit")
		get_tree().call_group("camera_limits", "adjust_limits",
			-10000000,
			10000000,
			-10000000,
			10000000)



