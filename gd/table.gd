# table.gd
extends HBoxContainer

var last_card_played: CardData = null


func play_card(card: CardData, player_name: String):
	if last_card_played and last_card_played.value == card.value:
		trigger_caida(player_name, card.value)

	last_card_played = card
	# Add visual representation to the table
	display_card_on_table(card)


func trigger_caida(player: String, value: int):
	print("¡CAÍDA! %s scored points with a %d" % [player, value])
	# Score calculation logic here (usually 1-4 points depending on card)
