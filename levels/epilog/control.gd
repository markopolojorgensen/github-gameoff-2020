extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$v_box_container/nugget_text.text = "Total Nuggets: " + String(global.total_nugget_count)
	$v_box_container/yeeted_text.text = "Total Rock Enemies Yeeted: " + String(global.yeet_count)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
