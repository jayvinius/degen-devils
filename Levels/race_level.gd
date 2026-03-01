extends Node2D

func _on_win_post_body_entered(body: Node2D) -> void:
	print(body.name)

func _on_timer_timeout() -> void:
	EventBus.start_race.emit()

