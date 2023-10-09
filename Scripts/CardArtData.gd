class_name CardArtData

extends Node

export var card_icons : Dictionary = {
	CardData.CardType.SKIP_CARD: preload("res://icon.png"),
	CardData.CardType.PLUS_2: preload("res://icon.png"),
	CardData.CardType.PLUS_4: preload("res://icon.png"),
	CardData.CardType.COLOR_SWITCH: preload("res://icon.png"),
}

export var color_cards : Dictionary = {
	CardData.CardColors.RED: preload("res://icon.png"),
	CardData.CardColors.GREEN: preload("res://icon.png"),
	CardData.CardColors.BLUE: preload("res://icon.png"),
	CardData.CardColors.YELLOW: preload("res://icon.png")
}
