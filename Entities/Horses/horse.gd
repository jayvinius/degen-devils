extends CharacterBody2D
class_name Horse

@export var acceleration: float = 5
@export var max_speed: float = 300
@export var horse_name: String = "Horse":
	set(v):
		horse_name = v
		%HorseNameLabel.text = v
@export var bet_amount: float = 0.0:
	set(v):
		bet_amount = v
		%BetAmountLabel.text = "$" + str(v)

enum State {
	IDLE,
	RUNNING,
	WIN,
	LOSE,
}

var state: State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	move_and_slide()

func run(_delta: float) -> void:
	velocity.x += acceleration
	if velocity.x > max_speed:
		velocity.x = max_speed

	# if not is_on_floor():
	# 	velocity += get_gravity() * delta

func _on_lower_bet_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if bet_amount >= 0:
		bet_amount -= 50
		player.money += 50

func _on_raise_bet_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player.money >= 50:
		bet_amount += 50
		player.money -= 50

func _on_bet_button_pressed() -> void:
	EventBus.emit_signal("place_bet", bet_amount)

func hide_ui() -> void:
	%BetUI.hide()
