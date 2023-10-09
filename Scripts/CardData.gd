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
	RED,
	GREEN,
	BLUE,
	YELLOW
}

var color: Color
var number: int = -1
var icon: Texture = null
var specialty: int = CardType.NONE

func set_data(color_val:Color, number_val:int, icon_val:Texture, specialty_val:int):
	color = color_val
	number = number_val
	icon = icon_val
	specialty = specialty_val

