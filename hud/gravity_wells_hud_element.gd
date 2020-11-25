extends HBoxContainer

func _ready():
	gravity_well_tracker.gravity_well_hud = self

func _process(delta):
	$label.text = String(gravity_well_tracker.available_wells)
	$shaker.increment(delta * 100)
	rect_position = $shaker.get_shake() * 5
	rect_rotation = $shaker.get_roll() * 11.25

func shake_it_up():
	$shaker.add_trauma(1)


