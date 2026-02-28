extends Control  # Changed from Area2D

signal card_played(data: CardData)

@export var card_data: CardData
@onready var sprite = $Area2D/Sprite2D
@onready var label = $Area2D/Label

var is_face_up: bool = true


func _ready():
	if card_data:
		update_visuals()

	mouse_entered.connect(func(): modulate = Color.GREEN)
	mouse_exited.connect(func(): modulate = Color.WHITE)

	# Control nodes use these signals for hover effects
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func update_visuals():
	if not card_data:
		return

	# Mapping Enums to Symbols
	var suit_sym = ""
	match card_data.suit:
		CardData.Suit.OROS:
			suit_sym = "🟡"  # Gold
		CardData.Suit.COPAS:
			suit_sym = "🏆"  # Cups
		CardData.Suit.ESPADAS:
			suit_sym = "⚔️"  # Swords
		CardData.Suit.BASTOS:
			suit_sym = "🪵"  # Clubs

	# Update the label to show "10 ⚔️" for example
	label.text = str(card_data.value) + "\n" + suit_sym

	# Optional: Color the text based on suit
	if card_data.suit == CardData.Suit.OROS:
		label.add_theme_color_override("font_color", Color.GOLD)


# For Control nodes, we use gui_input for clicks
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_face_up:
				print("Card clicked!")  # Add this to debug in the output console
				play_this_card()


func play_this_card():
	card_played.emit(card_data)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.chain().finished.connect(queue_free)


func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	z_index = 10


func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	z_index = 0


func set_is_face_up(value: bool):
	is_face_up = value
	if is_face_up:
		sprite.modulate = Color(1, 1, 1)  # Normal color
		label.visible = true
	else:
		sprite.modulate = Color(0.2, 0.2, 0.2)  # Dark/Hidden look
		label.visible = false
		# If you have a card back texture, use: sprite.texture = load("res://back.png")
