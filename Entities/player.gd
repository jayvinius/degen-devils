extends Node

@export var money: float = 100

@export var horse: Horse

@export var round: int

func _ready() -> void:
	round = 0
	horse = Horse.new()
	horse.set_base("accel", randf_range(5, 20.0))
	horse.set_base("max_speed", randf_range(300, 750.0))
	horse.player_horse = true
	EventBus.connect("buy_upgrade", upgrade_bought)

func upgrade_bought(upgrade: StringName) -> void:
	var drug := DrugRegistry.get_drug_by_id(upgrade)
	horse.add_drug(drug)
