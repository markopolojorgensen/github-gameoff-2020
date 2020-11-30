extends Node

export(int) var loud = 0
export(bool) var mute = false

var open = 16000
var closed = 1024

func _ready():
	global.music_manager = self
	fade_to_calm()

func plunger_hit():
	fade($music_calm, $music_upbeat)

func fade(from, to):
	if not mute:
		to.play(from.get_playback_position())
		$tween.interpolate_property(from, "volume_db", loud, -60, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		$tween.interpolate_property(to, "volume_db", -60, loud, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		$tween.start()

func fade_to_calm():
	if $music_calm.volume_db < -30:
		fade($music_upbeat, $music_calm)

func filter_fade_closed():
	$filter_tween.stop_all()
	var filter : AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("Filter"), 0)
	$filter_tween.interpolate_property(filter, "cutoff_hz", open, closed, 0.01, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$filter_tween.start()

func filter_fade_open():
	$filter_tween.stop_all()
	var filter : AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("Filter"), 0)
	$filter_tween.interpolate_property(filter, "cutoff_hz", closed, open, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$filter_tween.start()
