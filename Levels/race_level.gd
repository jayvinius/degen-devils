extends Node2D

var horse_bet_on: Horse
var race_won: bool = false

@export var horse_scene: PackedScene

func _ready() -> void:
	EventBus.connect("place_bet", bets_placed)

	# TODO: spawn all horses at the race line
	# holy shit this code is bad and I hate it with a passion
	# please fix this josh
	# seperate all of this data out to a resource maybe
	# something that persists
	var player_horse = horse_scene.instantiate()
	player_horse.set_base("accel", Player.horse.get_base("accel"))
	player_horse.set_base("max_speed", Player.horse.get_base("max_speed"))
	player_horse.horse_name = "AAAAAAAAA"
	player_horse.player_horse = true
	%Horses.add_child(player_horse)
	for drug in Player.horse.drugs:
		player_horse.add_drug(drug)
	print(player_horse.drugs)

	var highest_speed := 0.0
	for horse in %Horses.get_children():
		print("Horse Stats: ", horse.name, " accel: ", horse.get_stat("accel"), " max_speed: ", horse.get_stat("max_speed"))
		if horse.get_stat("max_speed") > highest_speed:
			highest_speed = horse.get_stat("max_speed")
	for horse in %Horses.get_children():
		horse.payout = roundf(highest_speed / horse.get_stat("max_speed") * 10.0) / 10.0

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
