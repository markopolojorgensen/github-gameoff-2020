extends Area2D

func _on_plunger_body_entered(body):
	if "is_player" in body:
		$animated_sprite.animation = "plunging"
		$plunge.play()
		global.level_manager.plunger_plunged = true
		
		# reset to defaults
		(global.camera as Camera2D).limit_bottom = 10000000
		(global.camera as Camera2D).limit_right = 10000000
		(global.camera as Camera2D).limit_left = -10000000
		(global.camera as Camera2D).limit_top = -10000000
