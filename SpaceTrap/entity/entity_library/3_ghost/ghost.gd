extends EntityStatable
class_name Ghost


@onready var animation: AnimatedSprite2D = $Animation


## 初始化-定制多个状态
func _init() -> void:
	_add_state(GhostStateIdle.new(self))
	_add_state(GhostStateMove.new(self))


## 帧更新前-设置起始状态
func _ready() -> void:
	transform_state("idle")
