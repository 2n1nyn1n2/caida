# player_hand.gd
extends HBoxContainer

@export var card_scene: PackedScene


func add_card_to_hand(data: CardData):
	var new_card = card_scene.instantiate()
	add_child(new_card)

	# Update the visual look of the card scene
	new_card.get_node("Sprite2D").texture = data.texture

	# Connect the signal for when the player clicks it
	new_card.input_event.connect(_on_card_clicked.bind(new_card, data))


func _on_card_clicked(_viewport, event, _shape_idx, card_node, data):
	if event is InputEventMouseButton and event.pressed:
		get_parent().play_card(data)
		card_node.queue_free()  # Remove from hand
