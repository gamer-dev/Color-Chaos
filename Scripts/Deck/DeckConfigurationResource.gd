#Resource class to control deck configuration
class_name DeckConfigurationResoure

extends Resource

#cards to give at start
export(int) var cards_to_deal = 7

#numbered cards config
export(int) var start_number = 0
export(int) var end_number = 9

#colors in deck
export(Array, CardData.CardColors) var card_colors = []

#special cards in deck which have colors
export(Array, CardData.CardType) var special_color_cards = []

#special cards which do not have any color
export(Array, CardData.CardType) var special_cards = []
