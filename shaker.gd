extends Node

# based on https://kidscancode.org/godot_recipes/2d/screen_shake/

# this isn't a noise maker, it's a shake maker

export(float) var decay = 0.8  # How quickly the shaking stops [0, 1].
export(int) var trauma_power = 2  # Trauma exponent. Use [2, 3].
var trauma = 0.0  # Current shake strength.

onready var noise = OpenSimplexNoise.new()
var noise_y = 0
var shake = Vector2()
var roll = 0

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func increment(delta):
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0.0)
		# shake()
		var amount = pow(trauma, trauma_power)
		noise_y += delta * 60
		roll = amount * noise.get_noise_2d(noise.seed, noise_y)
		shake.x = amount * noise.get_noise_2d(noise.seed*2, noise_y)
		shake.y = amount * noise.get_noise_2d(noise.seed*3, noise_y)

# returns a Vector2 with x & y between -1 & 1
func get_shake():
	return shake

# returns a scalar between -1 & 1
func get_roll():
	return roll

