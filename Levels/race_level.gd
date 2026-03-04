extends Node2D

var horse_bet_on: Horse
var race_won: bool = false

@export var horse_scene: PackedScene


func _process(delta: float) -> void:
	$PlayerFunds.text = "Player Funds $%.2f" % Player.money

func _ready() -> void:
	var spawns = %HorseSpawns.get_children()

	var player_horse = horse_scene.instantiate()
	player_horse.set_base("accel", Player.horse.accel)
	player_horse.set_base("max_speed", Player.horse.max_speed)
	player_horse.horse_name = Player.horse.horse_name
	player_horse.bet_amount = Player.horse.bet_amount
	player_horse.payout = Player.horse.payout
	player_horse.player_horse = true
	%Horses.add_child(player_horse)
	if Player.horse.texture:
		player_horse.texture = Player.horse.texture
	if spawns.size() > 0:
		player_horse.global_position = spawns[0].global_position
	for drug in Player.horse.drugs:
		player_horse.add_drug(drug)

	for i in Player.npc_horse_data.size():
		var data := Player.npc_horse_data[i]
		var npc_horse = horse_scene.instantiate()
		npc_horse.horse_name = data.horse_name
		npc_horse.bet_amount = data.bet_amount
		npc_horse.payout = data.payout
		npc_horse.set_base("accel", data.accel)
		npc_horse.set_base("max_speed", data.max_speed)
		if data.texture:
			npc_horse.texture = data.texture
		for drug in data.drugs:
			npc_horse.add_drug(drug)
		%Horses.add_child(npc_horse)
		var spawn_index = i + 1
		if spawn_index < spawns.size():
			npc_horse.global_position = spawns[spawn_index].global_position

	var highest_speed := 0.0
	for horse in %Horses.get_children():
		print("Horse Stats: ", horse.name, " accel: ", horse.get_stat("accel"), " max_speed: ", horse.get_stat("max_speed"))
		if horse.get_stat("max_speed") > highest_speed:
			highest_speed = horse.get_stat("max_speed")
	for horse in %Horses.get_children():
		horse.payout = roundf(highest_speed / horse.get_stat("max_speed") * 10.0) / 10.0

	for horse in %Horses.get_children():
		if horse.bet_amount > 0:
			horse_bet_on = horse
			break

	$Timer.start()

func _on_win_post_body_entered(body: Node2D) -> void:
	if race_won: return
	if body == horse_bet_on:
		body.win()
		print("you won")
	else:
		print("you lost")
	race_won = true
	%Finish.start()
	if body == horse_bet_on:
		%HorseWonLabel.text = "[rainbow freq=1.0][shake rate=10.0 level=5 connected=1]%s Won!\nYou made $%.2f[/shake][/rainbow]" % [body.horse_name, body.payout * body.bet_amount]
	else:
		%HorseWonLabel.text = "[rainbow freq=1.0][shake rate=10.0 level=5 connected=1]%s Won!\nYou lost $%.2f[/shake][/rainbow]" % [body.horse_name, horse_bet_on.bet_amount]
	%HorseWonLabel.show()
	EventBus.finish_race.emit()
	Player.round += 1

func _on_timer_timeout() -> void:
	EventBus.start_race.emit()

func _on_continue_button_pressed() -> void:
	LevelManager.goto_scene("res://Levels/upgrade_level.tscn")


func _on_finish_timeout() -> void:
	if Player.money <= 0:
		LevelManager.goto_scene("res://Levels/you_lose.tscn")
	else:
		LevelManager.goto_scene("res://Levels/upgrade_level.tscn")
