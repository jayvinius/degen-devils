extends DrugEffect
class_name OneTimeUseEffect

@export var id: StringName

func apply(owner: Node) -> void:
	EventBus.finish_race.connect(remove_self.bind(owner), CONNECT_ONE_SHOT)

func remove(owner: Node) -> void:
	pass

func remove_self(owner: Node) -> void:
	owner.remove_drug(DrugRegistry.get_drug_by_id(id))
