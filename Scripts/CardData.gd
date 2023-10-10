class_name CardData

extends Node

enum CardType {
	NONE = 0
	NUMBER = 1,
	SKIP_CARD = 2,
	PLUS_2 = 3,
	PLUS_4 = 4,
	COLOR_SWITCH = 5
}

enum CardColors {
	RED = 0,
	GREEN = 1,
	BLUE = 2,
	YELLOW = 3
}

var color: Color
var number: int = -1
var icon: Texture = null
var card_type: int = CardType.NONE

func set_data(color_val:Color, number_val:int, icon_val:Texture, card_type_val:int):
	color = color_val
	number = number_val
	icon = icon_val
	card_type = card_type_val

