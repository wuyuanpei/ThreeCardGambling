extends Node2D

signal hovered
signal hovered_off

var hand_position # 在手牌中的位置
var is_opponent # true为对手卡牌， false为自己卡牌

# 扑克牌信息
var suit
var point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be children of CardManager
	get_parent().connect_card_signals(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
