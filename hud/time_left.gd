extends Label

var shaking = false
var shake = 1
var delta_amount = 0
const shake_speed = 20

func convert_time(t):
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	var miliseconds = int(t * 1000) % 1000

	var time = ("%02d" % minutes) + (":%02d" % seconds) + (".%03d" % miliseconds)
	return time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time_left = global.end_timer.get_time_left()
	if time_left == 0:
		text = convert_time(global.end_timer.wait_time)
	else:
		text = convert_time(time_left)
		if time_left < 10:
			margin_left = margin_left + delta * shake * shake_speed
			delta_amount = delta_amount + delta * shake_speed
			if (delta_amount > 1):
				shake = shake * -1
				delta_amount = 0
