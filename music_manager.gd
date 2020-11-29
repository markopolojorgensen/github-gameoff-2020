extends Node

export(int) var loud = 0

func _ready():
	global.music_manager = self
	fade_to_calm()

func plunger_hit():
	fade($music_calm, $music_upbeat)

func fade(from, to):
	to.play(from.get_playback_position())
	$tween.interpolate_property(from, "volume_db", loud, -60, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$tween.interpolate_property(to, "volume_db", -60, loud, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$tween.start()

func fade_to_calm():
	if $music_calm.volume_db < -30:
		fade($music_upbeat, $music_calm)
