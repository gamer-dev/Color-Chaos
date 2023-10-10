extends Node

enum GameState {
	MENU,
	PLAY,
	OVER
}

enum TurnState{
	NONE,
	AI_PICK,
	PLAYER_PICK,
}

enum PlayerType{
	SELF,
	AI
}

onready var card_generator = $CardsGenerator
onready var deck_configurator = $DeckConfigurator
onready var player_card_holder = $SelfCardHolder
onready var ai_card_holder = $AICardHolder
onready var table_card_holder = $TableCardHolder
onready var player_turn_label = $PlayerTurnIndicator
onready var ai_turn_label = $AITurnIndicator

var facing_card_data : CardData
var facing_card_node : Node

var all_cards = []
var current_state = GameState.MENU
var current_turn_state = TurnState.NONE

var player_cards_nodes = []
var ai_cards_nodes = []

var current_deck_card_index: int = 0

func _ready():
	start_game()

func start_game():
	set_game_state(GameState.PLAY)
	setup_cards()

func set_game_state(new_game_state):
	current_state = new_game_state

func set_turn_state(new_turn_state):
	current_turn_state = new_turn_state
	if(current_turn_state == TurnState.PLAYER_PICK):
		player_turn_label.visible =true
		ai_turn_label.visible = false
	else:
		player_turn_label.visible = false
		ai_turn_label.visible = true

func setup_cards():
	all_cards = deck_configurator.generate_deck()
	randomize()
	all_cards.shuffle()
	#print("Type: %d, Number: %s" % [all_cards[0].card_type, all_cards[0].number])
	
	var cards_for_player = all_cards.slice(
		current_deck_card_index, 
		deck_configurator.deck_data.cards_to_deal-1
	)
	current_deck_card_index = deck_configurator.deck_data.cards_to_deal
	player_cards_nodes = card_generator.generate_cards(cards_for_player, player_card_holder, true)
	
	var cards_for_ai = all_cards.slice(
		current_deck_card_index, 
		current_deck_card_index + deck_configurator.deck_data.cards_to_deal-1
	)
	current_deck_card_index += deck_configurator.deck_data.cards_to_deal
	ai_cards_nodes = card_generator.generate_cards(cards_for_ai, ai_card_holder)
	
	var new_facing_card = all_cards[current_deck_card_index]
	update_facing_card(new_facing_card)
	current_deck_card_index +=1
	#give first turn to player always
	set_turn_state(TurnState.PLAYER_PICK)
	
func handle_card_selected(selected_card:Node):
	var selected_card_data = selected_card.this_card_data
	print("Card Data got = " , selected_card_data.card_type)
	if(current_turn_state == TurnState.PLAYER_PICK):
		print("Player has picked card")
		var can_pick = is_picked_card_valid(selected_card_data)
		print("Card can be picked? = ",can_pick)
		if(can_pick):
			handle_card_play(selected_card, PlayerType.SELF)

func is_picked_card_valid(picked_card:CardData):
	var can_pick:bool = false
	
	var is_same_type = picked_card.card_type == facing_card_data.card_type
	var is_same_number = true if (picked_card.number == facing_card_data.number && picked_card.number >=0) else false
	var is_same_color = picked_card.color == facing_card_data.color
	
	#checking for numbered cards:
	if(facing_card_data.card_type == CardData.CardType.NUMBER && (is_same_number || is_same_color)):
		can_pick = true
	
	#checking for special cards:
	if(facing_card_data.card_type != CardData.CardType.NUMBER && is_same_color):
		can_pick = true

	return can_pick
	
func handle_card_play(picked_card:Node, player_type):
	var picked_card_data:CardData = picked_card.this_card_data
	update_facing_card(picked_card_data)
	update_inhand_cards(picked_card, player_type)
	#switch turn
	handle_turn_update()
	pass
	
func update_inhand_cards(picked_card, player_type):
	var inhand_cards = player_cards_nodes if (player_type == PlayerType.SELF) else ai_cards_nodes
	
	if(player_type == PlayerType.SELF):
		inhand_cards = player_cards_nodes
	else:
		inhand_cards = ai_cards_nodes
	
	for card_node in inhand_cards:
		var is_color_match = card_node.this_card_data.color == picked_card.this_card_data.color
		var is_type_match = card_node.this_card_data.card_type == picked_card.this_card_data.card_type
		var is_number_match = card_node.this_card_data.number == picked_card.this_card_data.number
		
		if(is_number_match && is_type_match && is_color_match):
			inhand_cards.erase(card_node)
			card_node.queue_free()
			break
	
func update_facing_card(new_card:CardData):
	facing_card_data = new_card
	if(facing_card_node!=null):
		facing_card_node.queue_free()
	facing_card_node = null
	facing_card_node = card_generator.generate_cards([new_card], table_card_holder)[0]

func handle_turn_update():
	print("Updating turn")
	var new_turn_state = TurnState.AI_PICK if (current_turn_state == TurnState.PLAYER_PICK) else TurnState.PLAYER_PICK
	set_turn_state(new_turn_state)
	print("Turn switched, new turn state = ", current_turn_state)
	if(current_turn_state == TurnState.AI_PICK):
		yield(get_tree().create_timer(1.0), "timeout")
		print("1 second has passed. Continuing with AI turn.")
		handle_ai_turn()

func handle_ai_turn():
	print("Handling AI turn")
	#check if there is an eligible card or not
	#if eligible card, play and update turn
	var did_play_card = false
	for card in ai_cards_nodes:
		var card_data = card.this_card_data
		print("AI card - ", card_data.number)
		if(is_picked_card_valid(card_data)):
			did_play_card = true
			handle_card_play(card, PlayerType.AI)
			break;
	#if no eligible card, draw card and update turn
	if(!did_play_card):
		draw_deck_card(PlayerType.AI)

func draw_deck_card(player_type):
	var new_card = all_cards[current_deck_card_index]
	current_deck_card_index += 1
	if(player_type == PlayerType.SELF):
		var new_card_node = card_generator.generate_cards([new_card], player_card_holder)[0]
		player_cards_nodes.append(new_card_node)
	else:
		var new_card_node = card_generator.generate_cards([new_card], ai_card_holder)[0]
		ai_cards_nodes.append(new_card_node)
	handle_turn_update()

func _on_DrawCardButton_button_down():
	draw_deck_card(PlayerType.SELF)
