class_name BaseCard

extends Node

#data properties 
var this_card_data: CardData

#visual properties
onready var card_texture: TextureRect = $Texture
onready var card_icon : TextureRect = $Icon
onready var card_num_label : Label = $Number
onready var card_back_texture : TextureRect = $CardBack

var is_player_card: bool = true

func get_card_data():
	return this_card_data

func set_card_data(card_data_val:CardData, is_player = false, show_back = false):
	this_card_data = card_data_val
	is_player_card = is_player
	set_visuals(show_back)

func set_visuals(show_back:bool):
	set_card_texture(show_back)
	set_icon()
	set_number()
	pass
	
func set_card_texture(show_back:bool):
	card_texture.texture = this_card_data.texture
	if(!is_player_card):
		card_back_texture.visible = show_back
	
func set_icon():
	if is_instance_valid(this_card_data.icon):
		card_icon.texture = this_card_data.icon
		card_icon.modulate = this_card_data.color
		card_icon.visible = true
	else:
		card_icon.visible = false
			
func set_number():
	if this_card_data.number >= 0:
		card_num_label.text =  str(this_card_data.number)
		card_num_label.modulate = this_card_data.color
		card_num_label.visible = true
	else:
		card_num_label.visible = false
		
func _on_button_pressed():
	if(is_player_card):
		print("Card pressed!")
		var game_handler = get_tree().root.get_child(0)
		if(game_handler):
			game_handler.handle_card_selected(self)
