extends Node

onready var card_scene = preload("res://Scenes/Gameplay/Card.tscn")

func generate_cards(cards_to_generate, parent, is_player_card = false):
	var generated_cards = []
	for card in cards_to_generate:
		var card_instance = card_scene.instance() 
		parent.add_child(card_instance)
		#card_instance.visible = false
		if card_instance.has_method("set_card_data"):
			card_instance.set_card_data(card, is_player_card)
		else:
			print("set_card_data method not found in card_instance.")
		generated_cards.append(card_instance)
	return generated_cards
