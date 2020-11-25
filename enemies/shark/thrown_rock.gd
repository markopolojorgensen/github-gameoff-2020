extends RigidBody2D

export var direction = "custom"
export(Vector2) var custom_force
onready var horizontal_force = randi() % 100 + 150
onready var vertical_force = randi() % 50 + 50


var shake = 2
var delta_amount = 0
const shake_speed = 25
const drop_speed = 200

var shaking = false
var is_thrown_rock = true


func _process(delta):
	if shaking:
		position.x = position.x + delta * shake * shake_speed
		delta_amount = delta_amount + delta * shake_speed
		if (delta_amount > 1):
			shake = shake * -1
			delta_amount = 0

func _ready():
	if direction == "left":
		apply_central_impulse(Vector2.LEFT * horizontal_force)
		apply_central_impulse(Vector2.UP * vertical_force)
	elif direction == "right":
		apply_central_impulse(Vector2.RIGHT * horizontal_force)
		apply_central_impulse(Vector2.UP * vertical_force)
	else:
		apply_central_impulse(custom_force)
	$gone_timer.start()



func _on_thrown_rock_body_entered(body):
	if "is_player" in body:
		global.current_room.respawn_player_in_last_room(body)
		call_deferred("queue_free")


func _on_gone_timer_timeout():
	if not shaking:
		shaking = true
		$gone_timer.wait_time = 2
		$gone_timer.start()
		
	else:
		queue_free()
