class_name BaseCard

extends Area2D

#data properties 
var this_card_data: CardData

#visual properties
onready var card_sprite : Sprite = $Icon
onready var card_num_label : Label = $Number
onready var card_collision_shape : CollisionShape2D = $CollisionShape2D

func _ready():
	print("My card number is - " + card_num_label.text)

func set_card_data(card_data_val:CardData):
	this_card_data = card_data_val
	set_color(card_data_val.color)

func set_color(color: Color):
	pass
	
func set_icon():
	#card_sprite.texture = card_data_val.icon
	pass

func set_number():
	#card_num_label.text =  card_data_val.number
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
