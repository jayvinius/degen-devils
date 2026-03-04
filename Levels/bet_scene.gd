extends Control

const HORSE_NAMES = [
	"Thunderhoof", "Dusty Dan", "Sir Trots-a-Lot", "Glue Candidate",
	"Nag Supreme", "Oopsie Daisy", "Ol' Reliable", "Buckets McGee",
	"Spooky Boi", "Hay Fever", "Last Place Larry", "Knees McGee",
]

const HorseFileIndex = preload("res://horses/file_index.gd")
const HorseCardScene = preload("res://Entities/Horses/horse_card.tscn")

var _remaining_textures: Array[Texture2D] = []

func _random_texture() -> Texture2D:
	if _remaining_textures.is_empty():
		return null
	_remaining_textures.shuffle()
	return _remaining_textures.pop_back()

func _ready() -> void:
	for file in HorseFileIndex.FILES:
		if file.ends_with(".png"):
			_remaining_textures.append(load(file))

	_generate_horses()
	_populate_cards()
	_update_funds_label()
	_update_boss_label()

func _update_boss_label() -> void:
	var next_round := Player.round + 1
	if next_round > 0 and next_round % 3 == 0:
		var index := (next_round / 3) - 1
		if index < Player.bosses.size():
			var boss := Player.bosses[index]
			%BossInfoLabel.text = "Next race: Boss \"%s\" — Wager $%.2f" % [boss.boss_name, boss.wager]
			%BossInfoLabel.show()
			return
	%BossInfoLabel.hide()

func _update_funds_label() -> void:
	%PlayerFundsLabel.text = "Player Funds: $%.2f" % Player.money

func _generate_horses() -> void:
	Player.horse.bet_amount = 0.0

	# Assign player texture if not yet set
	if not Player.horse.texture:
		Player.horse.texture = _random_texture()
	else:
		_remaining_textures.erase(Player.horse.texture)

	# Generate NPC horses
	Player.npc_horse_data.clear()
	for i in 2:
		var npc := HorseData.new()
		npc.horse_name = HORSE_NAMES[randi() % HORSE_NAMES.size()]
		npc.accel = randf_range(5, 20.0)
		npc.max_speed = randf_range(300, 750.0)
		npc.texture = _random_texture()
		if Player.round > 0:
			for j in range(Player.round):
				npc.add_drug(DrugRegistry.get_random_drug())
		Player.npc_horse_data.append(npc)

	# Calculate payouts across all horses (using effective stats including drug effects)
	var highest_speed := Player.horse.get_effective_stat("max_speed")
	for npc in Player.npc_horse_data:
		if npc.get_effective_stat("max_speed") > highest_speed:
			highest_speed = npc.get_effective_stat("max_speed")
	Player.horse.payout = roundf(highest_speed / Player.horse.get_effective_stat("max_speed") * 10.0) / 10.0
	for npc in Player.npc_horse_data:
		npc.payout = roundf(highest_speed / npc.get_effective_stat("max_speed") * 10.0) / 10.0

func _on_start_race_button_pressed() -> void:
	LevelManager.goto_scene("res://Levels/race_level.tscn")

func _populate_cards() -> void:
	var player_card := HorseCardScene.instantiate()
	player_card.horse = Player.horse
	%Horses.add_child(player_card)
	player_card.bet_placed.connect(_on_any_bet_placed)

	for npc in Player.npc_horse_data:
		var card := HorseCardScene.instantiate()
		card.horse = npc
		%Horses.add_child(card)
		card.bet_placed.connect(_on_any_bet_placed)

func _on_any_bet_placed() -> void:
	%StartRaceButton.disabled = false
	_update_funds_label()
