extends Node2D

var horse_bet_on: Horse
var race_won: bool = false

@export var horse_scene: PackedScene

var _horse_textures: Array[Texture2D] = []

const HORSE_NAMES = [
	"Thunderhoof", "Dusty Dan", "Sir Trots-a-Lot", "Glue Candidate",
	"Nag Supreme", "Oopsie Daisy", "Ol' Reliable", "Buckets McGee",
	"Spooky Boi", "Hay Fever", "Last Place Larry", "Knees McGee",
]

func _load_horse_textures() -> void:
	var dir := DirAccess.open("res://horses")
	if not dir:
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".png"):
			_horse_textures.append(load("res://horses/" + file))
		file = dir.get_next()

func _random_texture() -> Texture2D:
	if _horse_textures.is_empty():
		return null
	_horse_textures.shuffle()
	return _horse_textures.pop_back()

func _ready() -> void:
	_load_horse_textures()
	EventBus.connect("place_bet", bets_placed)

	# TODO: spawn all horses at the race line
	# holy shit this code is bad and I hate it with a passion
	# please fix this josh
	# seperate all of this data out to a resource maybe
	# something that persists
	var spawns = %HorseSpawns.get_children()

	var player_horse = horse_scene.instantiate()
	player_horse.set_base("accel", Player.horse.get_base("accel"))
	player_horse.set_base("max_speed", Player.horse.get_base("max_speed"))
	player_horse.horse_name = "AAAAAAAAA"
	player_horse.player_horse = true
	%Horses.add_child(player_horse)
	if not Player.horse.texture:
		Player.horse.texture = _random_texture()
	player_horse.texture = Player.horse.texture
	if spawns.size() > 0:
		player_horse.global_position = spawns[0].global_position
	for drug in Player.horse.drugs:
		player_horse.add_drug(drug)
	print(player_horse.drugs)

	for i in 2:
		var npc_horse = horse_scene.instantiate()
		%Horses.add_child(npc_horse)
		npc_horse.horse_name = HORSE_NAMES[randi() % HORSE_NAMES.size()]
		npc_horse.texture = _random_texture()
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
	%Finish.start()
	if body == horse_bet_on:
		%HorseWonLabel.text = "[rainbow freq=1.0][shake rate=10.0 level=5 connected=1]%s Won!\nYou made $%.2f[/shake][/rainbow]" % [body.horse_name, body.payout * body.bet_amount]
	else:
		%HorseWonLabel.text = "[rainbow freq=1.0][shake rate=10.0 level=5 connected=1]%s Won!\nYou lost $%.2f[/shake][/rainbow]" % [body.horse_name, horse_bet_on.bet_amount]
	%HorseWonLabel.show()
	EventBus.finish_race.emit()

func _on_timer_timeout() -> void:
	EventBus.start_race.emit()

func _on_continue_button_pressed() -> void:
	LevelManager.goto_scene("res://Levels/upgrade_level.tscn")


func _on_finish_timeout() -> void:
	LevelManager.goto_scene("res://Levels/upgrade_level.tscn")
