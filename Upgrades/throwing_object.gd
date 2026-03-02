extends Area2D

@export var speed: float = 1250.0

var _direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	var thrower = get_parent()
	var target = _find_target(thrower)
	if target:
		_direction = (target.global_position - global_position).normalized()

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
