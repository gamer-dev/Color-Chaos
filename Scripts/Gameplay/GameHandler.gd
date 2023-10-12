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
	SELF = 0 ,
	AI = 1
}

onready var card_generator = $CardsGenerator
onready var deck_configurator = $DeckConfigurator
onready var player_card_holder = $SelfCardHolder
onready var ai_card_holder = $AICardHolder
onready var table_card_holder = $TableCardHolder
onready var player_turn_label = $PlayerTurnIndicator
onready var ai_turn_label = $AITurnIndicator
onready var draw_card_button = $DrawCardButton
onready var game_over_panel: Node = $GameOverPanel

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
	game_over_panel.visible = false
	set_game_state(GameState.PLAY)
	setup_cards()

func set_game_state(new_game_state):
	current_state = new_game_state

func set_turn_state(new_turn_state):
	current_turn_state = new_turn_state
	if(current_turn_state == TurnState.PLAYER_PICK):
		player_turn_label.visible =true
		ai_turn_label.visible = false
		tween_alpha(player_turn_label)
	else:
		player_turn_label.visible = false
		ai_turn_label.visible = true
		tween_alpha(ai_turn_label)

func setup_cards():
	all_cards = deck_configurator.generate_deck()
	randomize()
	all_cards.shuffle()
	
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
	ai_cards_nodes = card_generator.generate_cards(cards_for_ai, ai_card_holder, false, true)
	
	var new_facing_card = all_cards[current_deck_card_index]
	update_facing_card(new_facing_card)
	current_deck_card_index +=1
	#give first turn to player always
	set_turn_state(TurnState.PLAYER_PICK)
	
func handle_card_selected(selected_card:Node):
	var selected_card_data = selected_card.this_card_data
	if(current_turn_state == TurnState.PLAYER_PICK):
		var can_pick = is_picked_card_valid(selected_card_data)
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
	var is_special = process_special_card(picked_card.this_card_data, player_type)
	#switch turn
	if(!is_special):
		 handle_turn_update()
	
func process_special_card(card_data:CardData, player_type):
	var card_type = card_data.card_type 
	if(card_type != CardData.CardType.NONE && card_type != CardData.CardType.NUMBER):
		#we have a special card, handle it:
		match card_type:
			CardData.CardType.PLUS_2:
				handle_plus_two_played(player_type)
			CardData.CardType.TURN_JUMP:
				#TODO
				pass
		return true
	else:
		return false

func handle_plus_two_played(player_type):
	var add_cards_to = PlayerType.AI if (player_type == PlayerType.SELF) else PlayerType.SELF
	draw_deck_card(add_cards_to, 2)
	
func draw_deck_card(player_type, num_cards_to_draw = 1):
	if check_deck_size() and num_cards_to_draw > 0:
		var drawn_cards = []
		for i in range(num_cards_to_draw):
			if(check_deck_size()):
				var new_card = all_cards[current_deck_card_index]
				current_deck_card_index += 1
				drawn_cards.append(new_card)
		update_deck_visibility()
		if player_type == PlayerType.SELF:
			var new_card_nodes = card_generator.generate_cards(drawn_cards, player_card_holder, true)
			player_cards_nodes += new_card_nodes
		else:
			var new_card_nodes = card_generator.generate_cards(drawn_cards, ai_card_holder, false, true)
			ai_cards_nodes += new_card_nodes

		handle_turn_update()
	else:
		print("No Deck cards or invalid number of cards to draw! All finished!")
	
func check_deck_size():
	return current_deck_card_index < all_cards.size()
	
func update_deck_visibility():
	if(!check_deck_size()):
		draw_card_button.self_modulate = Color(1.0, 1.0, 1.0, 0.25)
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
			check_game_over(player_type)
			break

func check_game_over(player_type):
	if(player_type == PlayerType.SELF && player_cards_nodes.size() == 0):
		set_game_over()
	elif(player_type == PlayerType.AI && ai_cards_nodes.size() == 0):
		set_game_over()
		
func set_game_over():
	set_game_state(GameState.OVER)
	game_over_panel.visible = true
	
func update_facing_card(new_card:CardData):
	facing_card_data = new_card
	if(facing_card_node!=null):
		facing_card_node.queue_free()
	facing_card_node = null
	facing_card_node = card_generator.generate_cards([new_card], table_card_holder, false, false)[0]

func handle_turn_update():
	if(current_state == GameState.PLAY):
		var new_turn_state = TurnState.AI_PICK if (current_turn_state == TurnState.PLAYER_PICK) else TurnState.PLAYER_PICK
		set_turn_state(new_turn_state)
		if(current_turn_state == TurnState.AI_PICK):
			yield(get_tree().create_timer(1.0), "timeout")
			handle_ai_turn()

func handle_ai_turn():
	#check if there is an eligible card or not
	#if eligible card, play and update turn
	var did_play_card = false
	for card in ai_cards_nodes:
		var card_data = card.this_card_data
		if(is_picked_card_valid(card_data)):
			did_play_card = true
			handle_card_play(card, PlayerType.AI)
			break;
	#if no eligible card, draw card and update turn
	if(!did_play_card):
		draw_deck_card(PlayerType.AI)

func _on_DrawCardButton_button_down():
	if(current_turn_state == TurnState.PLAYER_PICK):
		draw_deck_card(PlayerType.SELF)

func tween_alpha(node):
	var tween = $Tween
	tween.stop_all()
	tween.interpolate_property(node, "modulate:a", 1.0, 0.25, 1.5 , Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	tween.set_repeat(true)
	tween.start()
	#tween.interpolate_method(player_turn_label, "set_position", Vector2.ZERO, size, 2, current_trans, current_ease)

func reload_main_scene():
	get_tree().reload_current_scene()
