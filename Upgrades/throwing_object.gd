extends Area2D

@export var speed: float = 1250.0
@export var aim_error: float = 100.0

var _direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	var notifier := VisibleOnScreenNotifier2D.new()
	add_child(notifier)
	notifier.screen_exited.connect(queue_free)

	var thrower = get_parent()
	var target = _find_target(thrower)
	if target:
		var intercept = _predict_intercept(target)
		_direction = (intercept - global_position).normalized()

func _predict_intercept(target: Node) -> Vector2:
	var d: Vector2 = target.global_position - global_position
	var tv: Vector2 = target.velocity

	# Quadratic: (tv·tv - speed²)t² + 2(d·tv)t + d·d = 0
	var a := tv.dot(tv) - speed * speed
	var b := 2.0 * d.dot(tv)
	var c := d.dot(d)

	var t := 0.0
	if abs(a) < 0.001:
		# Nearly linear — target speed negligible vs projectile
		if abs(b) > 0.001:
			t = -c / b
	else:
		var disc := b * b - 4.0 * a * c
		if disc >= 0.0:
			var sqrt_disc := sqrt(disc)
			var t1 := (-b + sqrt_disc) / (2.0 * a)
			var t2 := (-b - sqrt_disc) / (2.0 * a)
			if t1 > 0.0 and t2 > 0.0:
				t = min(t1, t2)
			elif t1 > 0.0:
				t = t1
			elif t2 > 0.0:
				t = t2

	var intercept = target.global_position if t <= 0.0 else target.global_position + tv * t
	return intercept + Vector2(randf_range(-aim_error, aim_error), randf_range(-aim_error, aim_error))

func _process(delta: float) -> void:
	global_position += _direction * speed * delta

func _find_target(thrower: Node) -> Node:
	var closest: Node = null
	var closest_dist := INF
	for horse in get_tree().get_nodes_in_group("horses"):
		if horse == thrower:
			continue
		var dist = global_position.distance_to(horse.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = horse
	return closest

func _on_body_entered(body: Node2D) -> void:
	if not body == get_parent():
		body.take_damage()
		queue_free()
