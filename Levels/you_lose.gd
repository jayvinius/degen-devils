extends Node2D


func _on_button_pressed() -> void:
	# Gross
	Player.round = 0
	Player.money = 100
	Player.horse = HorseData.new()
	Player.horse.accel = randf_range(5, 20.0)
	Player.horse.max_speed = randf_range(300, 750.0)
	Player.horse.texture = null
	Player.horse.drugs.clear()
	Player.horse.horse_name = "Trusty Steed"
	Player.npc_horse_data.clear()
	Player.bosses = Player._default_bosses.duplicate()
	LevelManager.goto_scene("res://Levels/main_menu.tscn")
