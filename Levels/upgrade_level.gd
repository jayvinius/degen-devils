extends Node2D

var drugs: Array[DrugData] = []
@export var drug_ui: PackedScene

var player_funds: float:
	set(v):
		player_funds = v
		%PlayerFundsLabel.text = "Player Funds: $%s" % player_funds

func _ready() -> void:
	for i in range(3):
		var drug := DrugRegistry.get_random_drug()
		drugs.append(drug)
		var drug_ui_node = drug_ui.instantiate()
		drug_ui_node.drug = drug
		%Upgrades.add_child(drug_ui_node)

# This sucks but on god, do I not care rn
func _process(delta: float) -> void:
	player_funds = Player.money

func _on_button_pressed() -> void:
	LevelManager.goto_scene("res://Levels/race_level.tscn")
