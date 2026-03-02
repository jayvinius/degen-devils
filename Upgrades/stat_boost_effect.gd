extends DrugEffect
class_name StatBoostEffect

@export var stat: StringName
@export var value: float
@export var is_multiplier: bool

func apply(owner: Node) -> void:
	owner.modify_stat(stat, value, is_multiplier)

func remove(owner: Node) -> void:
	owner.modify_stat(stat, -value, is_multiplier)
