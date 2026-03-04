extends DrugEffect
class_name TimerEffect

@export var interval: float = 1.0
@export var random_interval: bool = false
@export var interval_min: float = 0.5
@export var interval_max: float = 5.0

@export var scene: PackedScene
@export var hurt: bool = false

var _timer: Timer

func apply(owner: Node) -> void:
	_timer = Timer.new()
	_timer.wait_time = randf_range(interval_min, interval_max) if random_interval else interval
	_timer.autostart = false
	_timer.timeout.connect(_tick.bind(owner))
	owner.add_child(_timer)
	EventBus.connect("start_race", _start)
	owner.tree_exiting.connect(_on_owner_exiting)

func _on_owner_exiting() -> void:
	if EventBus.start_race.is_connected(_start):
		EventBus.start_race.disconnect(_start)
	_timer = null

func _start() -> void:
	if is_instance_valid(_timer) and _timer.is_stopped():
		_timer.start()

func remove(owner: Node) -> void:
	if EventBus.start_race.is_connected(_start):
		EventBus.start_race.disconnect(_start)
	if is_instance_valid(_timer):
		_timer.stop()
		_timer.queue_free()
	_timer = null

func _tick(owner: Node) -> void:
	if scene:
		var instance = scene.instantiate()
		owner.add_child(instance)
	if hurt:
		owner.state = Horse.State.HURT
