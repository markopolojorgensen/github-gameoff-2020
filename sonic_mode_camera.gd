extends Camera2D

export(bool) var draw_margin = false

const dims = Vector2(256, 144)
const half_dims = Vector2(128, 72)

func _process(delta):
	if global.camera_follow:
		global_position = global.camera_follow.global_position
	
	# snap player feet to roughly vertically centered when touching the ground
	if global.player and global.player.is_on_the_ground():
		drag_margin_bottom = lerp(drag_margin_bottom, 0, 7 * delta)
		drag_margin_top = lerp(drag_margin_bottom, 0, 7 * delta)
	else:
		drag_margin_bottom = lerp(drag_margin_bottom, 0.2, 20 * delta)
		drag_margin_top = lerp(drag_margin_bottom, 0.5, 20 * delta)
	
	drag_margin_left = lerp(drag_margin_left, 0.1, 5 * delta)
	drag_margin_right = lerp(drag_margin_left, 0.1, 5 * delta)

func _draw():
	if draw_margin:
		var top_left = Vector2(-half_dims.x * drag_margin_left, -half_dims.y * drag_margin_top)
		var bottom_right = Vector2(half_dims.x * drag_margin_right, half_dims.y * drag_margin_bottom)
		
		draw_rect(Rect2(-get_global_transform_with_canvas().origin + half_dims + top_left, bottom_right - top_left), Color.aliceblue, false)

func plunger_hit():
	# don't instantly snap camera over to center on player
	drag_margin_left = 1
	drag_margin_right = 1
	global_position = (global.camera as Camera2D).get_camera_screen_center()
	
	current = true
	global.camera = self

func adjust_limits(left, right, top, bottom):
	limit_left = left
	limit_right = right
	limit_top = top
	limit_bottom = bottom

func smooth_time_start():
	smoothing_enabled = true
	$smooth_time.start()

func _on_smooth_time_timeout():
	smoothing_enabled = false
