extends Label

var shaking = false
var shake = 1
var delta_amount = 0
const shake_speed = 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not global.easy_mode:
		if global.end_timer:
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
	else:
		if global.level_manager.plunger_plunged:
			if not global.level_manager.level_finished:
				text = global.convert_seconds_to_str((OS.get_ticks_msec() - global.level_manager.middle_time) / float(1000))
			else:
				text = global.convert_seconds_to_str((global.level_manager.end_time - global.level_manager.middle_time) / float(1000))
		else:
			text = ""
