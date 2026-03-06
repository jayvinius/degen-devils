extends CharacterBody2D
class_name Horse

@export var texture: Texture2D:
	set(v):
		texture = v
		if is_node_ready():
			$Sprite2D.texture = v

@export var horse_name: String = "Horse":
	set(v):
		horse_name = v
		%HorseNameLabel.text = v

@export var bet_amount: float = 0.0
@export var payout: float = 1.0:
	set(v):
		payout = v
		%PayoutLabel.text = "Payout: " + float_to_ratio(v)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var teleport_particles: GPUParticles2D

enum State {
	IDLE,
	RUNNING,
	WIN,
	LOSE,
	HURT,
}
var state: State = State.IDLE

var _stat_base: Dictionary = {}
var _stat_modifiers: Dictionary = {}

func set_base(stat: StringName, value: float) -> void:
	_stat_base[stat] = value

func modify_stat(stat: StringName, value: float, is_multiplier: bool) -> void:
	if stat not in _stat_modifiers:
		_stat_modifiers[stat] = { "flat": 0.0, "multi": 1.0}
	if _stat_base.has(stat):
		if is_multiplier:
			_stat_modifiers[stat]["multi"] *= value
		else:
			_stat_modifiers[stat]["flat"] += value

func get_stat(stat: StringName) -> float:
	if stat not in _stat_modifiers:
		return _stat_base[stat]
	return _stat_base[stat] * _stat_modifiers[stat]["multi"] + _stat_modifiers[stat]["flat"]

func get_base(stat: StringName) -> float:
	if stat not in _stat_base:
		return 0.0
	return _stat_base[stat]

@export var max_health: int = 1
var health: int

@export var player_horse: bool = false
var horse_data: HorseData
var bonus_placing: int = 1
var place_payout: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	if texture:
		$Sprite2D.texture = texture
	# This is jank and I will do something different
	# *eventually*
	if not player_horse and _stat_base.is_empty():
		set_base("accel", randf_range(5, 20.0))
		set_base("max_speed", randf_range(300, 750.0))

	add_to_group("horses")

	EventBus.connect("start_race", start_race)

func start_race() -> void:
	state = State.RUNNING

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			pass
		State.RUNNING:
			run(delta)
		State.WIN:
			pass
		State.LOSE:
			pass
		State.HURT:
			hurt()
	move_and_slide()

func run(_delta: float) -> void:
	animation_player.play("running")
	velocity.x += get_stat("accel")
	if velocity.x > get_stat("max_speed"):
		velocity.x = get_stat("max_speed")

	# if not is_on_floor():
	# 	velocity += get_gravity() * delta

func hurt() -> void:
	animation_player.play("hurt")
	velocity.x = 0


func take_damage() -> void:
	print('ow')
	health -= 1
	if health <= 0:
		state = State.HURT
		health = 1
		%HurtTimer.start()

func win() -> void:
	Player.money += bet_amount * payout + bet_amount

## Gross float to ratio
func float_to_ratio(value: float, max_denominator: int = 1000) -> String:
	if value == 0.0:
		return "0:1"

	var negative := value < 0.0
	value = abs(value)

	var best_num := 1
	var best_den := 1
	var best_error := INF

	for den in range(1, max_denominator + 1):
		var num := roundi(value * den)
		var error:float = abs(value - float(num) / float(den))
		if error < best_error:
			best_error = error
			best_num = num
			best_den = den
		if error < 1e-9:
			break

	var g := gcd(best_num, best_den)
	best_num /= g
	best_den /= g

	if negative:
		return "-%d : %d" % [best_num, best_den]
	return "%d : %d" % [best_num, best_den]

func gcd(a: int, b: int) -> int:
	while b != 0:
		var t := b
		b = a % b
		a = t
	return a

@export var drugs: Array[DrugData] = []

signal item_added(item: DrugData)
signal item_removed(item: DrugData)

func add_drug(drug: DrugData) -> void:
	var d := drug.duplicate(true)
	drugs.append(d)
	for effect in d.effects:
		effect.apply(self)
	emit_signal("item_added", d)

func remove_drug(drug: DrugData) -> void:
	drugs.erase(drug)
	for effect in drug.effects:
		effect.remove(self)
	emit_signal("item_removed", drug)

func _on_hurt_timer_timeout() -> void:
	state = State.RUNNING
