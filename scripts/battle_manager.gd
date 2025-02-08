extends Node

var confirm_button
var battle_timer

@onready var card_slot: Node2D = $"../CardSlot"
@onready var card_slot_2: Node2D = $"../CardSlot2"
@onready var card_slot_3: Node2D = $"../CardSlot3"

@onready var opponent_hand: Node2D = $"../OpponentHand"
@onready var player_hand: Node2D = $"../PlayerHand"

@onready var card_slot_opponent: Node2D = $"../CardSlotOpponent"
@onready var card_slot_opponent_2: Node2D = $"../CardSlotOpponent2"
@onready var card_slot_opponent_3: Node2D = $"../CardSlotOpponent3"
@onready var opponent_win_text: RichTextLabel = $"../OpponentWinText"
@onready var player_win_text: RichTextLabel = $"../PlayerWinText"
@onready var player_score: RichTextLabel = $"../PlayerScore"
@onready var opponent_score: RichTextLabel = $"../OpponentScore"
@onready var deck: Node2D = $"../Deck"
@onready var game_count: RichTextLabel = $"../GameCount"

var turns = [] # 图标
var turns_result = [] # 回合结果 true为玩家胜利
var turn_index = 0 # 当前是第几回合 （0,1,2）
var opponent_turn = false
var green_circle
var red_circle

var new_game = false # 开始下一局游戏
var game_index = 0 # 局编号

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_timer = $"../BattleTimer"
	confirm_button = $"../Button"
	confirm_button.disabled = true
	player_win_text.visible = false
	opponent_win_text.visible = false
	turns.push_back($"../TurnRecord".get_node("Turn1"))
	turns.push_back($"../TurnRecord".get_node("Turn2"))
	turns.push_back($"../TurnRecord".get_node("Turn3"))
	turns[0].visible = false
	turns[1].visible = false
	turns[2].visible = false
	green_circle = preload("res://assets/green-circle.png")
	red_circle = preload("res://assets/red-circle.png")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# 检查允许按下confirm_button
func check_confirm_button_open():
	if card_slot.card_in_slot != null and card_slot_2.card_in_slot != null and card_slot_3.card_in_slot != null:
		confirm_button.disabled = false
	else:
		confirm_button.disabled = true

# 确定按钮按下
func _on_button_pressed() -> void:
	# sanity check
	if card_slot.card_in_slot == null or card_slot_2.card_in_slot == null or card_slot_3.card_in_slot == null:
		check_confirm_button_open()
		return
	
	# 对手回合，无法右键撤回
	opponent_turn = true
	
	# 对手思考时间
	$"../Button".disabled = true
	battle_timer.wait_time = 0.5
	battle_timer.start()
	await battle_timer.timeout
	
	# 对手随机选取三张牌
	var card_index = randi() % opponent_hand.player_hand.size() # 第一张
	var card = opponent_hand.player_hand[card_index]
	# 移动卡牌
	opponent_hand.remove_card_from_hand(card)
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", card_slot_opponent.position, 0.2)
	card.get_node("Area2D/CollisionShape2D").disabled = true # 无法再拖动和悬停
	
	var card_index2 = randi() % opponent_hand.player_hand.size() # 第二张
	var card2 = opponent_hand.player_hand[card_index2]
	# 移动卡牌
	opponent_hand.remove_card_from_hand(card2)
	tween.tween_property(card2, "position", card_slot_opponent_2.position, 0.2)
	card2.get_node("Area2D/CollisionShape2D").disabled = true # 无法再拖动和悬停
	
	var card_index3 = randi() % opponent_hand.player_hand.size() # 第二张
	var card3 = opponent_hand.player_hand[card_index3]
	# 移动卡牌
	opponent_hand.remove_card_from_hand(card3)
	tween.tween_property(card3, "position", card_slot_opponent_3.position, 0.2)
	card3.get_node("Area2D/CollisionShape2D").disabled = true # 无法再拖动和悬停
	
	# 翻转三张卡牌
	battle_timer.wait_time = 1.0
	battle_timer.start()
	await battle_timer.timeout
	card.get_node("AnimationPlayer").play("card_flip")
	card2.get_node("AnimationPlayer").play("card_flip")
	card3.get_node("AnimationPlayer").play("card_flip")
	
	# 胜负判定和加分
	check_win(card_slot.card_in_slot, card_slot_2.card_in_slot, card_slot_3.card_in_slot, 
		card, card2, card3)
	
	# 清除这几张牌
	battle_timer.wait_time = 3.0
	battle_timer.start()
	await battle_timer.timeout
	card_slot.card_in_slot.queue_free()
	card_slot_2.card_in_slot.queue_free()
	card_slot_3.card_in_slot.queue_free()
	card.queue_free()
	card2.queue_free()
	card3.queue_free()
	
	player_win_text.visible = false
	opponent_win_text.visible = false
	
	opponent_turn = false
	
	# 重置游戏
	if new_game == true:
		new_game = false
		
		# 回合数据清空
		turns_result.clear()
		turns[0].visible = false
		turns[1].visible = false
		turns[2].visible = false
		turn_index = 0
		
		# 手牌清空
		player_hand.remove_all_cards_from_hand()
		opponent_hand.remove_all_cards_from_hand()
		
		# 重新洗牌并发牌
		deck.restart_game()
		
		# 局数更新
		game_index += 1
		game_count.text = "局: " + str(game_index)
	
	# 若未结束，抽一张牌
	else:
		deck.draw_card()
		deck.draw_card_opponent()

# true为玩家赢， false为对手赢
func check_win(my_card1, my_card2, my_card3, op_card1, op_card2, op_card3):
	print(my_card1.suit + str(my_card1.point) + " " + my_card2.suit + str(my_card2.point) + " " + my_card3.suit + str(my_card3.point))
	print(op_card1.suit + str(op_card1.point) + " " + op_card2.suit + str(op_card2.point) + " " + op_card3.suit + str(op_card3.point))
	var my_res = check_type_and_value(my_card1, my_card2, my_card3)
	var op_res = check_type_and_value(op_card1, op_card2, op_card3)
	
	# 玩家赢
	if my_res[0] > op_res[0] or (my_res[0] == op_res[0] and my_res[1] > op_res[1]):
		player_win_text.text = map_win_text(my_res[0])
		player_win_text.visible = true
		turns[turn_index].texture = green_circle
		turns_result.push_back(true)
	# 对手赢
	else:
		opponent_win_text.text = map_win_text(op_res[0])
		opponent_win_text.visible = true
		turns[turn_index].texture = red_circle
		turns_result.push_back(false)
	
	turns[turn_index].visible = true
	turn_index += 1
	
	# 检查是否终局
	if turns_result.size() == 2:
		if turns_result[0] == true and turns_result[1] == true:
			player_score.text = str(int(player_score.text) + 1)
			new_game = true
		if turns_result[0] == false and turns_result[1] == false:
			opponent_score.text = str(int(opponent_score.text) + 1)
			new_game = true
	
	if turns_result.size() == 3:
		if turns_result[2] == true:
			player_score.text = str(int(player_score.text) + 1)
			new_game = true
		if turns_result[2] == false:
			opponent_score.text = str(int(opponent_score.text) + 1)
			new_game = true
		
func map_win_text(win_type):
	if win_type == 5:
		return "同花顺！"
	if win_type == 4:
		return "三条！"
	if win_type == 3:
		return "顺子！"
	if win_type == 2:
		return "同花！"
	if win_type == 1:
		return "对子！"
	if win_type == 0:
		return "单张高牌！"
	return "胜利！"

# 返回 [牌型，大小]
# 牌型：从小到大，0为高牌，1为对子，2为同花，3为顺子，4为三条，5为同花顺
# 大小：相同牌型比较大小
func check_type_and_value(card1, card2, card3):
	
	var cards_point = [card1.point, card2.point, card3.point]
	cards_point.sort()
	
	var cards_value = [card_to_value(card1.suit, card1.point), card_to_value(card2.suit, card2.point), card_to_value(card3.suit, card3.point)]
	cards_value.sort()
	
	# 同花顺
	if (card1.suit == card2.suit and card1.suit == card3.suit) and ((cards_point[0] == (cards_point[1] - 1) and cards_point[1] == (cards_point[2] - 1)) or 
		(cards_point[0] == 2 and cards_point[1] == 3 and cards_point[2] == 14)):
		
		if (cards_point[0] == 2 and cards_point[1] == 3 and cards_point[2] == 14): # A 2 3的同花顺，以3作为最大数
			return [5, cards_value[1]]
		else:
			return [5, cards_value[2]]
	
	# 三条
	if cards_point[0] == cards_point[1] and cards_point[0] == cards_point[2]:
		return [4,0]
	
	# 顺子
	if (cards_point[0] == (cards_point[1] - 1) and cards_point[1] == (cards_point[2] - 1)) or (cards_point[0] == 2 and cards_point[1] == 3 and cards_point[2] == 14):
		
		if (cards_point[0] == 2 and cards_point[1] == 3 and cards_point[2] == 14): # A 2 3的同花顺，以3作为最大数
			return [3, cards_value[1]]
		else:
			return [3, cards_value[2]]
			
	# 同花
	if card1.suit == card2.suit and card1.suit == card3.suit:
		return [2, cards_value[2]]
		
	# 对子
	if cards_point[0] == cards_point[1] or cards_point[1] == cards_point[2]:
		if cards_point[0] == cards_point[1]:
			return [1, cards_value[2] + cards_point[2] * 100 + cards_point[1] * 10000] # 优先比较主对的值，再比较踢脚的值，若踢脚值相同，比较三张牌最大值的牌
		else:
			return [1, cards_value[2] + cards_point[0] * 100 + cards_point[1] * 10000]
	
	# 高牌
	return [0, cards_value[2]]
	
# 返回单个卡牌大小
func card_to_value(suit, point):
	if suit == "diamonds":
		return point * 4
	if suit == "clubs":
		return point * 4 + 1
	if suit == "hearts":
		return point * 4 + 2
	if suit == "spades":
		return point * 4 + 3
	else:
		return 0
