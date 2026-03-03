extends DrugEffect
class_name OneTimeUseEffect

@export var id: StringName

func apply(owner: Node) -> void:
	EventBus.connect("finish_race", remove_self.bind(owner))

func remove(owner: Node) -> void:
	pass

func remove_self(owner: Node) -> void:
	owner.remove_drug(DrugRegistry.get_drug_by_id(id))
