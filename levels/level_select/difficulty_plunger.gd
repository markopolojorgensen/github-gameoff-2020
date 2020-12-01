extends Area2D

var plunged = false
var resetting = true

func _ready():
	$animated_sprite.play()
	set_text()

func _on_difficulty_plunger_body_entered(body):
	if not plunged and "is_player" in body :
		$animated_sprite.play("plunging")
		$plunge.play()
		$plunge_reset_timer.start()
		plunged = true
		resetting = true
		global.easy_mode = !global.easy_mode
		set_text()
		global.level_manager.save_game()
		
func set_text():
	if global.easy_mode:
		$label.text = "easy mode active"
	else:
		$label.text = "normal mode active"

func _on_plunge_reset_timer_timeout():
	if resetting:
		$animated_sprite.play("plunging", true)
		$plunge_reset_timer.start()
		resetting = false
	else:
		plunged = false
		$animated_sprite.animation = "default"
