extends Resource
class_name DrugData

@export var id: StringName
@export var drug_name: String
@export var price: float
@export var description: String
@export var icon: Texture2D
@export var rarity: Rarity
@export var effects: Array[DrugEffect] = []

enum Rarity { COMMON, RARE, LEGENDARY }
