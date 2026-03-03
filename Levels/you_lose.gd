extends Node2D


func _on_button_pressed() -> void:
	# Gross
	Player.round = 0
	Player.money = 100
	Player.horse = Horse.new()
	Player.horse.set_base("accel", randf_range(5, 20.0))
	Player.horse.set_base("max_speed", randf_range(300, 750.0))
	Player.horse.player_horse = true
	LevelManager.goto_scene("res://Levels/main_menu.tscn")
