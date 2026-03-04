extends Resource
class_name HorseData

@export var horse_name: String = "Trusty Steed"
@export var accel: float = 0.0
@export var max_speed: float = 0.0
@export var texture: Texture2D
@export var drugs: Array[DrugData] = []
var bet_amount: float = 0.0
var payout: float = 1.0

func get_effective_stat(stat_name: StringName) -> float:
	var base: float = get(stat_name)
	var flat := 0.0
	var multi := 1.0
	for drug in drugs:
		for effect in drug.effects:
			if effect is StatBoostEffect and effect.stat == stat_name:
				if effect.is_multiplier:
					multi *= effect.value
				else:
					flat += effect.value
	return base * multi + flat

func add_drug(drug: DrugData) -> void:
	drugs.append(drug.duplicate(true))

func remove_drug(drug: DrugData) -> void:
	drugs.erase(drug)
