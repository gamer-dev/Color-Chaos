class_name DeckConfigurator

extends Node

export(Resource) var deck_data
var card_art_data : CardArtData
var all_cards = []

# Called when the node enters the scene tree for the first time.
func _ready():
	card_art_data = $"CardArtData"
	
func generate_deck():
	print("Generating Deck!")
	for color in deck_data.card_colors:
		generate_number_cards(color)
		generate_special_color_cards(color)
	#generate_special_cards()
	print("Total Cards in Deck:", all_cards.size())
	return all_cards
	
func generate_number_cards(color):
	for i in range(deck_data.start_number, deck_data.end_number+1):
		var card_data = CardData.new()
		card_data.set_data(
			card_art_data.colors[color], 
			i,
			card_art_data.color_cards_sprites[color], 
			null, 
			CardData.CardType.NUMBER
		)
		all_cards.append(card_data)

func generate_special_color_cards(color):
	for special_color_card in deck_data.special_color_cards:
		var card_data = CardData.new()
		card_data.set_data(
			card_art_data.colors[color], 
			-1, 
			card_art_data.color_cards_sprites[color],
			card_art_data.card_icons[special_color_card], 
			special_color_card
		)
		all_cards.append(card_data)
		
func generate_special_cards():
	for special_card in deck_data.special_cards:
		var card_data = CardData.new()
		card_data.set_data(
			-1, 
			-1, 
			null, 
			card_art_data.card_icons[special_card], 
			special_card
		)
		all_cards.append(card_data)
