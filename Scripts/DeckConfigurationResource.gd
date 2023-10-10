#Resource class to control deck configuration

class_name DeckConfigurationResoure

extends Resource

#numbered cards config
export(int) var start_number = 0
export(int) var end_number = 9

#colors in deck
export(Array, CardData.CardColors) var cardColors = []

#special cards in deck which are influenced by colors
export(Array, CardData.CardType) var specialColorCards = []

#special cards which are not influenced by color
export(Array, CardData.CardType) var specialCards = []
