extends CharacterBody2D

@export var acceleration: float = 5
@export var max_speed: float = 300

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
			print("idle")
		State.RUNNING:
			run(delta)
		State.WIN:
			print("win")
		State.LOSE:
			print("lose")
	move_and_slide()

func run(_delta: float) -> void:
	velocity.x += acceleration
	if velocity.x > max_speed:
		velocity.x = max_speed

	# if not is_on_floor():
	# 	velocity += get_gravity() * delta
