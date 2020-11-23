extends RigidBody2D

export var direction = "left"
onready var horizontal_force = randi() % 100 + 150
onready var vertical_force = randi() % 50 + 50

# Called when the node enters the scene tree for the first time.
func _ready():
	if direction == "left":
		apply_central_impulse(Vector2.LEFT * horizontal_force)
	else:
		apply_central_impulse(Vector2.RIGHT * horizontal_force)
	apply_central_impulse(Vector2.UP * vertical_force)



func _on_thrown_rock_body_entered(body):
	if "is_player" in body:
		global.current_room.respawn_player_in_last_room(body)
		call_deferred("queue_free")
