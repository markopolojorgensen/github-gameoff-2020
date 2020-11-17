extends Area2D

var Radius = 2
var RotateSpeed = 2
onready var _centre = global_position
onready var _angle = randf() * 360

var picked_up = false

func _ready():
	if randi() % 2 == 1:
		RotateSpeed = RotateSpeed * -1

func _process(delta):
	_angle += RotateSpeed * delta;
	var offset = Vector2(sin(_angle), cos(_angle)) * Radius;
	global_position = _centre + offset
	

func _on_nugget_body_entered(body):
	if not picked_up and "is_player" in body:
		global.nugget_count += 1
		picked_up = true
		$pickup.play()
		$tween.interpolate_property($sprite, "modulate", Color(1, 1, 1, 1), Color(0, 0, 0, 0),
		.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$tween.start()
		yield(get_tree().create_timer(.5), "timeout")
		queue_free()

