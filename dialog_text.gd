extends Area2D

export (String) var dialog_text

var triggered = false

func _on_dialog_text_body_entered(body):
	if not triggered and "is_player" in body:
		triggered = true
		global.player_hud.show_text(dialog_text)
		call_deferred("queue_free")
