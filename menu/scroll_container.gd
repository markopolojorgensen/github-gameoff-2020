extends ScrollContainer

const high_score_row_scene = preload("res://hud/high_score_row.tscn")

class StrToIntSorter:
	static func sort_ascending(a, b):
		return int(a) < int(b)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not global.level_manager.best_level_times:
		print("this should only fire once")
		global.level_manager.load_game()
	
	for n in $v_box_container.get_children():
		$v_box_container.remove_child(n)
		n.queue_free()
		
	var best_times = global.level_manager.best_level_times
	var keys = best_times.keys()
	keys.sort_custom(StrToIntSorter, "sort_ascending")
	for key in keys:
		var row = high_score_row_scene.instance()
		row.get_node("level").text = "Chapter " + String(int(key) + 1)
		row.get_node("return_time").text = global.convert_seconds_to_str(best_times[key]["return_time"] / 1000)
		row.get_node("total_time").text = global.convert_seconds_to_str(best_times[key]["total_time"] / 1000)
		$v_box_container.add_child(row)


func _on_control_visibility_changed():
	if self.visible:
		_ready()
