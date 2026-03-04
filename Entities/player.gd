extends Node

@export var money: float = 100

@export var horse: HorseData
var npc_horse_data: Array[HorseData] = []

@export var round: int

@export var bosses: Array[BossData] = []
var _default_bosses: Array[BossData] = []

func current_boss() -> BossData:
	if round == 0 or round % 3 != 0:
		return null
	var index := (round / 3) - 1
	if index >= bosses.size():
		return null
	return bosses[index]

func _ready() -> void:
	_default_bosses = bosses.duplicate()
	round = 0
	horse = HorseData.new()
	horse.accel = randf_range(5, 20.0)
	horse.max_speed = randf_range(300, 750.0)
	EventBus.connect("buy_upgrade", upgrade_bought)

func upgrade_bought(upgrade: StringName) -> void:
	var drug := DrugRegistry.get_drug_by_id(upgrade)
	horse.add_drug(drug)
