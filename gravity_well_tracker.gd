extends Node

var gravity_well_hud

var gravity_wells = {}

# current room tracker
var available_wells = 0

func register_room(room_name):
	gravity_wells[room_name] = []

func can_add_well():
	return global.current_room and (gravity_wells[global.current_room.name].size() < global.current_room.number_of_wells)

func add_well(well):
	if not can_add_well():
		print("shouldn't be adding a well in room %s!" % global.current_room.name)
	
	gravity_wells[global.current_room.name].append(well)
	update()

func remove_well(well):
	if gravity_wells[global.current_room.name].has(well):
		gravity_wells[global.current_room.name].erase(well)
	else:
		print("tried to remove well from %s, but it wasn't there!" % global.current_room.name)
	
	update()

func update():
	available_wells = global.current_room.number_of_wells - gravity_wells[global.current_room.name].size()

