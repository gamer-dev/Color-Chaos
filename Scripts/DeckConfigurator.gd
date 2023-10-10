class_name DeckConfigurator

extends Node

export(Resource) var deck_data

var card_art_data : CardArtData

var all_cards = []

# Called when the node enters the scene tree for the first time.
func _ready():
	card_art_data = $CardArtData
	generate_deck()
	
func generate_deck():
	print("Generating Deck!")
	for color in deck_data.cardColors:
		generate_number_cards(color)
		#generate_special_color_cards(color)

	#generate_special_cards()
	
func generate_number_cards(color):
	for i in range(deck_data.start_number, deck_data.end_number+1):
		var card_data = CardData.new()
		print("Access card color = " , color)
		card_data.set_data(card_art_data.colors[0], i, null, CardData.CardType.NUMBER)
		all_cards.append(card_data)
		print("Cards length:", all_cards.size())
		
func generate_special_color_cards(color):
	
	for i in range(deck_data.start_number, deck_data.end_number+1):
		print("Index:", i)
		
func generate_special_cards():
	pass
	
	for i in range(deck_data.start_number, deck_data.end_number+1):
		print("Index:", i)
