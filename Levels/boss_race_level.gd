extends Node2D

var race_won: bool = false

@export var horse_scene: PackedScene

func _process(_delta: float) -> void:
	$PlayerFunds.text = "Player Funds $%.2f" % Player.money

func _ready() -> void:
	var boss := Player.current_boss()
	var spawns = %HorseSpawns.get_children()

	%BossInfoLabel.text = "%s\nWager: $%.2f" % [boss.boss_name, boss.wager]

	var player_horse = horse_scene.instantiate()
	player_horse.set_base("accel", Player.horse.accel)
	player_horse.set_base("max_speed", Player.horse.max_speed)
	player_horse.horse_name = Player.horse.horse_name
	player_horse.player_horse = true
	if Player.horse.texture:
		player_horse.texture = Player.horse.texture
	for drug in Player.horse.drugs:
		player_horse.add_drug(drug)
	%Horses.add_child(player_horse)
	if spawns.size() > 0:
		player_horse.global_position = spawns[0].global_position

	if boss.horse:
		var boss_horse = horse_scene.instantiate()
		boss_horse.set_base("accel", boss.horse.accel)
		boss_horse.set_base("max_speed", boss.horse.max_speed)
		boss_horse.horse_name = boss.horse.horse_name
		if boss.horse.texture:
			boss_horse.texture = boss.horse.texture
		for drug in boss.horse.drugs:
			boss_horse.add_drug(drug)
		%Horses.add_child(boss_horse)
		if spawns.size() > 1:
			boss_horse.global_position = spawns[1].global_position

	$Timer.start()

func _on_win_post_body_entered(body: Node2D) -> void:
	if race_won: return
	race_won = true

	var wager := Player.current_boss().wager

	if body.player_horse:
		Player.money += wager
		%HorseWonLabel.text = "[rainbow freq=1.0][shake rate=10.0 level=5 connected=1]You beat the boss!\nYou won $%.2f[/shake][/rainbow]" % wager
	else:
		Player.money -= wager
		%HorseWonLabel.text = "[rainbow freq=1.0][shake rate=10.0 level=5 connected=1]Boss won!\nYou lost $%.2f[/shake][/rainbow]" % wager

	%HorseWonLabel.show()
	EventBus.finish_race.emit()
	%Finish.start()

func _on_timer_timeout() -> void:
	EventBus.start_race.emit()

func _on_finish_timeout() -> void:
	if Player.money <= 0:
		LevelManager.goto_scene("res://Levels/you_lose.tscn")
	else:
		LevelManager.goto_scene("res://Levels/bet_scene.tscn")
