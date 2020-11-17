extends CanvasLayer

func _process(delta):
	$nugget_count.text = String(global.nugget_count)
