extends Label

var shaking = false
var shake = 1
var delta_amount = 0
const shake_speed = 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time_left = global.end_timer.get_time_left()
	if time_left == 0:
		text = global.convert_seconds_to_str(global.end_timer.wait_time)
	else:
		text = global.convert_seconds_to_str(time_left)
		if time_left < 10:
			margin_left = margin_left + delta * shake * shake_speed
			delta_amount = delta_amount + delta * shake_speed
			if (delta_amount > 1):
				shake = shake * -1
				delta_amount = 0
