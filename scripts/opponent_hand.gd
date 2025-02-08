extends Node2D

const CARD_WIDTH = 150
const HAND_Y_POSITION = 50

var player_hand = [] # 所有手牌 此处player实际为对手
var center_screen_x # 手牌以屏幕中间为参照

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport_rect().size.x / 2


# 将该牌插入手牌第一张，并更新位置和执行动画
func add_card_to_hand(card):
	player_hand.insert(0, card)
	update_hand_positions() # 更新位置和执行动画

# 将该牌插入手牌最后一张，并更新位置和执行动画
func append_card_to_hand(card):
	player_hand.push_back(card)
	update_hand_positions() # 更新位置和执行动画

# 更新手牌显示位置
func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position)
		

# 计算每张卡牌的位置
func calculate_card_position(index):
	var first_x_offset = (player_hand.size() - 1) / 2.0 * CARD_WIDTH
	var x_position = center_screen_x - first_x_offset + index * CARD_WIDTH
	return x_position

# 将卡牌动画到位置
func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.2)

# 将卡牌从手牌中移除
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()

# 将所有卡牌从手牌中移除
func remove_all_cards_from_hand():
	for card in player_hand:
		card.queue_free()
	
	player_hand.clear()
