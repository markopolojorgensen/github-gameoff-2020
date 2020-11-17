extends Area2D

var RotateSpeed = 2
var Radius = 1
onready var _centre = global_position
var _angle = 0

var picked_up = false

func _process(delta):
	_angle += RotateSpeed * delta;
	var offset = Vector2(sin(_angle), cos(_angle)) * Radius;
	global_position = _centre + offset
	

func _on_nugget_body_entered(body):
	if not picked_up and "is_player" in body:
		picked_up = true
		$pickup.play()
		$tween.interpolate_property($sprite, "modulate", Color(1, 1, 1, 1), Color(0, 0, 0, 0),
		.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$tween.start()
		yield(get_tree().create_timer(.5), "timeout")
		queue_free()
		global.nugget_count += 1
