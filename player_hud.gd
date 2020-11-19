extends CanvasLayer

func _process(_delta):
	$nugget_count.text = String(global.nugget_count)
