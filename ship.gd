extends Area2D

func _on_ship_body_entered(body):
	if "is_player" in body and body.is_player:
		global.level_manager.ship_entered()
