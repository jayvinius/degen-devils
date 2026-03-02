extends DrugEffect
class_name TimerEffect


@export var interval: float = 1.0
@export var scene: PackedScene

var _timer: Timer

func apply(owner: Node) -> void:
	_timer = Timer.new()
	_timer.wait_time = interval
	_timer.autostart = false
	_timer.timeout.connect(_tick.bind(owner))
	owner.add_child(_timer)
	EventBus.connect("start_race", _start)

func _start() -> void:
	if _timer.is_stopped():
		_timer.start()

func remove(owner: Node) -> void:
	if _timer:
		_timer.stop()
		_timer.queue_free()
		_timer = null

func _tick(owner: Node) -> void:
	if scene:
		var instance = scene.instantiate()
		owner.add_child(instance)
