extends Camera2D


func _process(_delta):
	if global.camera_follow:
		global_position = global.camera_follow.global_position
	else:
		print("nothing for camera to follow!")
	


