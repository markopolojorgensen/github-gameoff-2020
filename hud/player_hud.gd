extends CanvasLayer

var additional_text = false
var text_sequence = []
var current_sequence = 0

func _ready():
	global.player_hud = self

func show_text(text):
	if "|" in text:
		_initialize_multiline()
		var chunks = text.split("|")

		for chunk in chunks:
			var new_sequence = []
			_split_text(chunk, new_sequence)
			text_sequence += new_sequence
			
		$control/text_box/h_box_container/text.text = text_sequence[current_sequence]
		$control/text_box.show()
		$control/text_box/ellipses.show()
			
		
	elif text.length() < 100:
		additional_text = false
		$control/text_box/h_box_container/text.text = text
		$control/text_box.show()
		$control/text_box/ellipses.hide()
		
	else:
		_initialize_multiline()
		_split_text(text, text_sequence)
		$control/text_box/h_box_container/text.text = text_sequence[current_sequence]
		$control/text_box.show()
		$control/text_box/ellipses.show()

	get_tree().paused = true

func _initialize_multiline():
	additional_text = true
	text_sequence = []
	current_sequence = 0
	
func _split_text(text, sequence):
	if text.length() < 100:
		sequence.append(text.strip_edges())
		return

	var split_index = text.rfind(" ", 90) # hopefully we don't have any 10+ letter words
	sequence.append(text.substr(0, split_index).strip_edges())
	_split_text(text.substr(split_index, -1).strip_edges(), sequence) # the +1 on split_index is to remove the space at the beginning of the next slide
		
	
func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		if additional_text:
			current_sequence += 1

			# resume on last text input
			if current_sequence > text_sequence.size() - 1:
				_resume_game()

			else:
				# hide ellipses on last box
				if current_sequence == text_sequence.size() - 1:
					$control/text_box/ellipses.hide()
				# update text!
				$control/text_box/h_box_container/text.text = text_sequence[current_sequence]

		else:
			_resume_game()

func _resume_game():
	$control/text_box.hide()
	get_tree().paused = false


