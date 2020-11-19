extends Node2D

export(bool) var play_sprite = false
export(bool) var play_sound = false

func _ready():
	if play_sprite:
		$animated_sprite.play()
	
	if play_sound:
		$audio_stream_player_2d.play()

func _on_timer_timeout():
	queue_free()
