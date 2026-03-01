extends Node2D

func _ready() -> void:
	EventBus.connect("place_bet", bets_placed)

func bets_placed(amount: float) -> void:
	for horse in %Horses.get_children():
		horse.hide_ui()

	$Timer.start()

func _on_win_post_body_entered(body: Node2D) -> void:
	print(body.name)

func _on_timer_timeout() -> void:
	EventBus.start_race.emit()
