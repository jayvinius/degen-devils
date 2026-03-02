extends Node

var drugs: Array[DrugData] = []

func _ready() -> void:
	load_drugs("res://Upgrades/Drugs")

func load_drugs(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Failed to open directory: " + path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var drug = load(path + "/" + file_name) as DrugData
			if drug:
				drugs.append(drug)
			else:
				push_error("Failed to load drug: " + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func get_random_drug() -> DrugData:
	if drugs.size() == 0:
		push_error("No drugs loaded")
		return null

	var index = randi() % drugs.size()
	return drugs[index]

func get_drug_by_name(drug_name: String) -> DrugData:
	for drug in drugs:
		if drug.name == drug_name:
			return drug
	return null

func get_drug_by_id(id: StringName) -> DrugData:
	for drug in drugs:
		if drug.id == id:
			return drug
	return null
