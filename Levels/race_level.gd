extends Node2D

var horse_bet_on: Horse
var race_won: bool = false

func _ready() -> void:
	EventBus.connect("place_bet", bets_placed)

	var highest_speed := 0.0
	for horse in %Horses.get_children():
		if horse.max_speed > highest_speed:
			highest_speed = horse.max_speed
	for horse in %Horses.get_children():
		horse.payout = highest_speed / horse.max_speed

func bets_placed(amount: float, path: NodePath) -> void:
	for horse in %Horses.get_children():
		horse.hide_ui()

	horse_bet_on = get_node(path)

	$Timer.start()

func _on_win_post_body_entered(body: Node2D) -> void:
	if race_won: return
	if body == horse_bet_on:
		body.win()
		print("you won")
	else:
		print("you lost")
	race_won = true
	$ContinueButton.show()

func _on_timer_timeout() -> void:
	EventBus.start_race.emit()

func _on_continue_button_pressed() -> void:
	LevelManager.goto_scene("res://Levels/upgrade_level.tscn")
