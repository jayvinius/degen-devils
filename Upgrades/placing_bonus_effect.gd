extends DrugEffect
class_name PlacingBonusEffect

@export var bonus_placing: int = 2
@export var place_payout: float = 0.5

func apply(owner: Node) -> void:
	owner.bonus_placing = bonus_placing
	owner.place_payout = place_payout

func remove(owner: Node) -> void:
	owner.bonus_placing = 1
	owner.place_payout = 0.0
