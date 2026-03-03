extends DrugEffect
class_name TeleportEffect

@export var interval: float = 1.0

var _timer: Timer

var _stop_timer: Timer

func apply(owner: Node) -> void:
	_timer = Timer.new()
	_timer.wait_time = randf_range(.25, 2)
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
	owner.position.x += randf_range(-300, 300)
	owner.teleport_particles.emitting = true
	_stop_timer = Timer.new()
	_stop_timer.wait_time = .3
	_stop_timer.autostart = true
	_stop_timer.timeout.connect(_stop_tick.bind(owner))
	owner.add_child(_stop_timer)

func _stop_tick(owner: Node) -> void:
	owner.teleport_particles.emitting = false
