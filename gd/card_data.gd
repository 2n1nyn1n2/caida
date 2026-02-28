# card_data.gd
class_name CardData extends Resource

enum Suit { OROS, COPAS, ESPADAS, BASTOS }

@export var value: int  # 1 to 12 (Spanish Deck)
@export var suit: Suit
@export var texture: Texture2D
