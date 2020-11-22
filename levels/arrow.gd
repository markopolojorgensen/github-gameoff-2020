extends Node2D

export(bool) var flip = false

func _ready():
	if flip:
		$sprite.flip_h = true

func plunger_hit():
	# could do either, whatever
	hide()
	queue_free()
