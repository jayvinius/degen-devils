extends Node

@export var money: float = 100

func _ready() -> void:
	add_to_group("player")
