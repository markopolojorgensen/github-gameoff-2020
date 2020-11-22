extends Camera2D

const speed = 200

var moving_right = true
# global coordinates
var desired_position := Vector2()

func _ready():
	global.camera = self

func _process(delta):
	if global.camera_follow:
		# coordinates relative to top-left corner of screen
		var target = (global.camera_follow as CanvasItem).get_global_transform_with_canvas().origin
		if moving_right:
			var anchor_to_target = target.x - $right_anchor.get_global_transform_with_canvas().origin.x
			if anchor_to_target > 0:
				# target is to the right of anchor, catch up!
				desired_position.x = global_position.x + anchor_to_target
			elif $left_threshold.get_global_transform_with_canvas().origin.x > target.x:
				# player passed the left threshold, switch directions
				moving_right = false
		else:
			var anchor_to_target = target.x - $left_anchor.get_global_transform_with_canvas().origin.x
			if anchor_to_target < 0:
				# target is to the left of anchor, catch up!
				desired_position.x = global_position.x + anchor_to_target
			elif $right_threshold.get_global_transform_with_canvas().origin.x < target.x:
				# player passed the right threshold, switch directions
				moving_right = true
		desired_position.y = global.camera_follow.global_position.y
	else:
		print("nothing for camera to follow!")
	
	if global_position.distance_to(desired_position) < (speed * delta):
		global_position = desired_position
	else:
		global_position += global_position.direction_to(desired_position) * speed * delta


func adjust_limits(left, right, top, bottom):
	limit_left = left
	limit_right = right
	limit_top = top
	limit_bottom = bottom



