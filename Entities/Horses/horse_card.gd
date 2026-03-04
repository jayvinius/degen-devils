extends PanelContainer

const BET_AMOUNT := 50.0

@export var horse: HorseData:
	set(v):
		horse = v
		if horse and is_node_ready():
			_populate()

func _ready() -> void:
	if horse:
		_populate()

func _populate() -> void:
	$HBoxContainer/NameLabel.text = horse.horse_name
	$HBoxContainer/TextureRect.texture = horse.texture
	$"HBoxContainer/Payout Label".text = "Payout: " + _float_to_ratio(horse.payout)
	_update_bet_label()

func _update_bet_label() -> void:
	$HBoxContainer/HBoxContainer/BetAmountLabel.text = "Bet: $%.0f" % horse.bet_amount

signal bet_placed

func _on_button_pressed() -> void:
	if Player.money >= BET_AMOUNT:
		Player.money -= BET_AMOUNT
		horse.bet_amount += BET_AMOUNT
		_update_bet_label()
		emit_signal("bet_placed")

func _float_to_ratio(value: float, max_denominator: int = 1000) -> String:
	if value == 0.0:
		return "0:1"
	var best_num := 1
	var best_den := 1
	var best_error := INF
	for den in range(1, max_denominator + 1):
		var num := roundi(value * den)
		var error: float = abs(value - float(num) / float(den))
		if error < best_error:
			best_error = error
			best_num = num
			best_den = den
		if error < 1e-9:
			break
	var g := _gcd(best_num, best_den)
	return "%d:%d" % [best_num / g, best_den / g]

func _gcd(a: int, b: int) -> int:
	while b != 0:
		var t := b
		b = a % b
		a = t
	return a
