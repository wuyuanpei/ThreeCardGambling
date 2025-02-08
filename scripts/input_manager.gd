extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const COLLISION_MASK_DECK = 4

var card_manager_reference
var deck_reference
var player_hand_reference
@onready var battle_manager: Node = $"../BattleManager"


func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"
	player_hand_reference = $"../PlayerHand"

# 鼠标点击和释放操作
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor_left()
		else:
			emit_signal("left_mouse_button_released")
			#card_manager_reference.on_left_click_released() #似乎也可以直接调用，不必用signal回调
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			raycast_at_cursor_right()

# 判断左击的物体
func raycast_at_cursor_left():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager_reference.start_drag(card_found)
		#elif result_collision_mask == COLLISION_MASK_DECK:
			#deck_reference.draw_card()

# 判断右击的物体
func raycast_at_cursor_right():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD_SLOT:
			var card_slot = result[0].collider.get_parent()
			if card_slot.card_in_slot != null and battle_manager.opponent_turn == false:
				var card = card_slot.card_in_slot
				player_hand_reference.append_card_to_hand(card)
				card.get_node("Area2D/CollisionShape2D").disabled = false # 恢复拖动和悬停能力
				card_slot.card_in_slot = null # 恢复空位
				battle_manager.check_confirm_button_open() # 重新检查确定按钮是否打开
			
