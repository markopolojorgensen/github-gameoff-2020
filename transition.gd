extends CanvasLayer

signal halfway

func _ready():
	global.transition = self
	

func do_transition():
	$animation_player.play("transition")

func halfway():
	emit_signal("halfway")
