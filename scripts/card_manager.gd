extends Node2D


const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

const CARD_ORIGINAL_SCALE = 0.4
const CARD_HOVERED_SCALE = 0.43

var screen_size # avoid card out of screen
var card_being_dragged
var card_dragging_mouse_offset # 拖拽时鼠标和卡牌的偏移量
var is_hovering_on_card
var player_hand_reference

@onready var battle_manager: Node = $"../BattleManager"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
# 每一帧处理拖拽位置
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x- card_dragging_mouse_offset.x, 0, screen_size.x), 
			clamp(mouse_pos.y - card_dragging_mouse_offset.y, 0, screen_size.y))


func start_drag(card):
	card_being_dragged = card
	card_dragging_mouse_offset = get_global_mouse_position() - card_being_dragged.position
	card.scale = Vector2(CARD_ORIGINAL_SCALE, CARD_ORIGINAL_SCALE)


func on_left_click_released():
	if card_being_dragged:
		finish_drag()
		
func finish_drag():
	# check card slot below it
	var card_slot_found = raycast_check_for_card_slot()
	
	# 拖到一个空的槽位中且拖的牌为己方卡牌，并无法再拖动和悬停
	if card_slot_found and card_slot_found.card_in_slot == null and !card_being_dragged.is_opponent: 
		card_being_dragged.position = card_slot_found.position # set card position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true # 无法再拖动和悬停
		card_slot_found.card_in_slot = card_being_dragged
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		battle_manager.check_confirm_button_open() # 检查是否可以按下确定按钮
		
	# 返回至手牌对应位置
	else:
		player_hand_reference.animate_card_to_position(card_being_dragged, card_being_dragged.hand_position)
	card_being_dragged.scale = Vector2(CARD_ORIGINAL_SCALE, CARD_ORIGINAL_SCALE)
	card_being_dragged = null

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = card_being_dragged.position
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	else:
		return null


# 鼠标悬停在卡牌上
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

# 将卡牌放大并置于其他卡牌上层
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_HOVERED_SCALE, CARD_HOVERED_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(CARD_ORIGINAL_SCALE, CARD_ORIGINAL_SCALE)
		card.z_index = 1
		
func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		#check if hovered off card straight onto another card
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_hightest_z(result)
	else:
		return null

func get_card_with_hightest_z(cards):
	# assume first card in array has the hightest z
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		var current_z = current_card.z_index
		if current_z > highest_z:
			highest_z_card = current_card
			highest_z = current_z
	return highest_z_card

			
