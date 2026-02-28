extends Control
class_name game_gd

# We'll use the CardData resource we defined earlier
var winning_score: int = 24
var deck: Array[CardData] = []
var last_card_played: CardData = null
var player_score: int = 0
var cpu_score: int = 0

@onready var player_hand_node = %PlayerHand
@onready var table_node = %Table
@onready var status_label = %StatusMessage
@onready var score_label = %ScoreLabel
@onready var deck_count_label = %DeckCountLabel


func _ready():
	setup_deck()
	%DealButton.pressed.connect(deal_round)


func _process(_delta):
	%MouseLight.position = get_local_mouse_position()
	#print(%MouseLight.position)


func update_score_display():
	%ScoreLabel.text = "Player: %d | CPU: %d" % [player_score, cpu_score]


func setup_deck():
	deck.clear()
	# Caída uses 40 cards (No 8s or 9s)
	for suit in CardData.Suit.values():
		for val in [1, 2, 3, 4, 5, 6, 7, 10, 11, 12]:
			var card = CardData.new()
			card.suit = suit
			card.value = val
			deck.append(card)
	deck.shuffle()
	update_deck_ui()


func add_card_to_player_hand(data: CardData):
	# Assuming you have a 'card.tscn'
	var card_scene = load("res://tscn/card.tscn")
	var card_instance = card_scene.instantiate()

	# Pass data to the card instance
	card_instance.card_data = data
	player_hand_node.add_child(card_instance)

	# Connect a signal so we know when the player plays it
	card_instance.card_played.connect(_on_card_played)


func check_for_winner():
	if player_score >= winning_score:
		game_over("YOU WIN!")
	elif cpu_score >= winning_score:
		game_over("CPU WINS!")


func game_over(message: String):
	%StatusMessage.text = message
	%StatusMessage.modulate.a = 1.0
	%DealButton.text = "PLAY AGAIN"

	# Reset score for next game
	player_score = 0
	# Optional: Disable clicking cards here


func show_message(text: String):
	status_label.text = text
	# Simple 4.6 Tween to fade the message out
	var tween = create_tween()
	status_label.modulate.a = 1.0
	tween.tween_property(status_label, "modulate:a", 0.0, 1.5).set_delay(1.0)


func update_table_visual(data: CardData):
	# 1. Don't delete EVERYTHING. Just limit the stack to, say, 3 cards
	var current_cards = %LastPlayedCardSlot.get_children()
	if current_cards.size() > 2:
		current_cards[0].queue_free()  # Remove the oldest card if the stack is too big

	# 2. Darken the previous card so it looks like it's "underneath"
	for child in current_cards:
		child.modulate = Color(0.5, 0.5, 0.5)  # Gray out old cards
		child.z_index -= 1  # Move it visually behind

	# 3. Instantiate the new "Real Card"
	var card_scene = load("res://tscn/card.tscn")
	var table_card = card_scene.instantiate()
	table_card.card_data = data
	table_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	%LastPlayedCardSlot.add_child(table_card)

	# 4. Give it a random slight rotation so it looks like a messy pile
	table_card.rotation_degrees = randf_range(-10, 10)

	# 5. Position and Animate
	table_card.position = -table_card.custom_minimum_size / 2
	table_card.scale = Vector2(1.5, 1.5)

	var tween = create_tween()
	tween.tween_property(table_card, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)


func deal_round():
	if deck.size() == 0:
		show_message("ROUND OVER - SHUFFLING")
		setup_deck()

	# Deal 3 to each
	for i in range(3):
		if deck.size() > 0:
			add_card_to_player_hand(deck.pop_back())
		if deck.size() > 0:
			add_card_to_opponent_hand(deck.pop_back())

	update_deck_ui()


func add_card_to_opponent_hand(data: CardData):
	var card_scene = load("res://tscn/card.tscn")
	var card_instance = card_scene.instantiate()

	card_instance.card_data = data
	%OpponentHand.add_child(card_instance)

	# Important: Tell the card to show its BACK
	card_instance.set_is_face_up(false)


func _on_card_played(data: CardData):
	# Check if Player got a match
	if last_card_played and last_card_played.value == data.value:
		check_for_caida_logic(data, "Player")

	last_card_played = data
	update_table_visual(data)

	# CPU Turn
	await get_tree().create_timer(1.0).timeout
	cpu_play_turn()


func cpu_play_turn():
	var opponent_hand = %OpponentHand.get_children()
	if opponent_hand.size() == 0:
		return

	var card_node = opponent_hand[0]
	var data = card_node.card_data

	# Check if CPU got a match
	if last_card_played and last_card_played.value == data.value:
		check_for_caida_logic(data, "CPU")

	last_card_played = data
	update_table_visual(data)
	card_node.queue_free()


func check_for_match(data: CardData, puncher: String):
	if last_card_played and last_card_played.value == data.value:
		if puncher == "PLAYER":
			player_score += 1
			show_message("¡CAÍDA!")
		else:
			show_message("CPU CAÍDA!")
		score_label.text = "Score: %d" % player_score


func cpu_scored():
	cpu_score += 1
	# Assuming you have a second label or update the main one:
	%ScoreLabel.text = "P: %d | CPU: %d" % [player_score, cpu_score]

	if cpu_score >= winning_score:
		game_over("CPU WINS...")


func show_status_animation():
	# Reset visibility and scale for the pop effect
	%StatusMessage.modulate.a = 1.0
	%StatusMessage.scale = Vector2(0.5, 0.5)

	var tween = create_tween()
	# Make it "pop" up to full size with a bounce
	tween.tween_property(%StatusMessage, "scale", Vector2(1.2, 1.2), 0.3).set_trans(
		Tween.TRANS_ELASTIC
	)
	# Then fade it out slowly after a small delay
	tween.tween_property(%StatusMessage, "modulate:a", 0.0, 1.0).set_delay(1.5)


func update_deck_ui():
	%DeckCountLabel.text = "Cards in Deck: " + str(deck.size())


func check_for_caida_logic(data: CardData, who_played: String):
	if last_card_played != null and last_card_played.value == data.value:
		# 1. Point for the Caída
		var points_gained = 1

		# 2. Add "Limpia" bonus (If you match the card, the table is now 'clear')
		points_gained += 1

		if who_played == "Player":
			player_score += points_gained
			%StatusMessage.text = "¡CAÍDA Y LIMPIA!"
		else:
			cpu_score += points_gained
			%StatusMessage.text = "CPU: CAÍDA Y LIMPIA!"

		# Reset the table so the NEXT person can't match a ghost card
		last_card_played = null
		update_score_display()
		show_status_animation()
	else:
		# No match? Just update the "last card" for the next player
		last_card_played = data
