extends Node2D

var player_funds: float:
	set(v):
		player_funds = v
		%PlayerFundsLabel.text = "Player Funds: $%s" % player_funds

func _ready() -> void:
	player_funds = Player.money


func _on_button_pressed() -> void:
	LevelManager.goto_scene("res://Levels/race_level.tscn")
