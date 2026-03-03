extends Control

@export var price: float

@export var drug: DrugData:
	set(v):
		drug = v
		if drug:
			%UpgradeLabel.text = drug.drug_name
			%DescriptionLabel.text = drug.description
			%PriceLabel.text = "Price: $%s" % drug.price
		else:
			%UpgradeLabel.text = "No Drug"
			%DescriptionLabel.text = ""
			%PriceLabel.text = ""

func _on_button_pressed() -> void:
	if Player.money >= drug.price:
		Player.money -= drug.price
		EventBus.emit_signal("buy_upgrade", drug.id)
		hide()


func _on_rich_text_label_mouse_entered() -> void:
	%BuyText.text = "[rainbow]Buy[/rainbow]"


func _on_buy_text_mouse_exited() -> void:
	%BuyText.text = "Buy"
