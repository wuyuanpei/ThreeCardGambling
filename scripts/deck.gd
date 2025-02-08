extends Node2D

const CARD_SCENE_PATH = "res://scenes/card.tscn"
var player_deck_const = ["clubs_ace", "clubs_02", "clubs_03", "clubs_04", "clubs_05", "clubs_06", "clubs_07",
	"clubs_08", "clubs_09", "clubs_10", "clubs_jack", "clubs_queen", "clubs_king",
	"diamonds_ace", "diamonds_02", "diamonds_03", "diamonds_04", "diamonds_05", "diamonds_06", "diamonds_07",
	"diamonds_08", "diamonds_09", "diamonds_10", "diamonds_jack", "diamonds_queen", "diamonds_king",
	"hearts_ace", "hearts_02", "hearts_03", "hearts_04", "hearts_05", "hearts_06", "hearts_07",
	"hearts_08", "hearts_09", "hearts_10", "hearts_jack", "hearts_queen", "hearts_king",
	"spades_ace", "spades_02", "spades_03", "spades_04", "spades_05", "spades_06", "spades_07",
	"spades_08", "spades_09", "spades_10", "spades_jack", "spades_queen", "spades_king"
	]
var player_deck
var card_database_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck = player_deck_const.duplicate(true)
	player_deck.shuffle() # 洗混数组
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://scripts/card_database.gd")
	get_node("AnimationPlayer").play("initial_draw")

func restart_game():
	player_deck = player_deck_const.duplicate(true)
	player_deck.shuffle() # 洗混数组
	$RichTextLabel.text = str(player_deck.size())
	get_node("AnimationPlayer").play("initial_draw")

func draw_card():
	
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name) # 删去第一张牌
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true # 不再可以被点击
		$Sprite2D.visible = false # 消失
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	
	# 生成一张卡牌
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.name = "Card" # 设置名称
	# 设置图片
	var card_image_path = str("res://assets/Casino/Cards/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	
	new_card.position = position # 初始位置为deck的位置
	new_card.is_opponent = false # 卡牌属于者
	
	#卡牌花色点数
	new_card.suit = card_drawn_name.substr(0, card_drawn_name.find("_"))
	var point_str = card_drawn_name.substr(card_drawn_name.find("_") + 1)
	if point_str == "jack":
		new_card.point = 11
	elif point_str == "queen":
		new_card.point = 12
	elif point_str == "king":
		new_card.point = 13
	elif point_str == "ace":
		new_card.point = 14
	else:
		new_card.point = int(point_str)
	
	$"../CardManager".add_child(new_card)
	$"../PlayerHand".add_card_to_hand(new_card)
	
	new_card.get_node("AnimationPlayer").play("card_flip")


# 对手抽牌
func draw_card_opponent():
	
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name) # 删去第一张牌
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true # 不再可以被点击
		$Sprite2D.visible = false # 消失
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	
	# 生成一张卡牌
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.name = "Card" # 设置名称
	# 设置图片
	var card_image_path = str("res://assets/Casino/Cards/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	
	new_card.position = position # 初始位置为deck的位置
	new_card.is_opponent = true # 卡牌属于者
	
	#卡牌花色点数
	new_card.suit = card_drawn_name.substr(0, card_drawn_name.find("_"))
	var point_str = card_drawn_name.substr(card_drawn_name.find("_") + 1)
	if point_str == "jack":
		new_card.point = 11
	elif point_str == "queen":
		new_card.point = 12
	elif point_str == "king":
		new_card.point = 13
	elif point_str == "ace":
		new_card.point = 14
	else:
		new_card.point = int(point_str)
	
	$"../CardManager".add_child(new_card)
	$"../OpponentHand".add_card_to_hand(new_card)
	
	#new_card.get_node("AnimationPlayer").play("card_flip")
