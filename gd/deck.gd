# deck.gd
var cards: Array[CardData] = []


func initialize_deck():
	for s in CardData.Suit.values():
		for v in [1, 2, 3, 4, 5, 6, 7, 10, 11, 12]:
			var new_card = CardData.new()
			new_card.suit = s
			new_card.value = v
			# new_card.texture = load("res://assets/cards/%d_%d.png" % [s, v])
			cards.append(new_card)
	cards.shuffle()
