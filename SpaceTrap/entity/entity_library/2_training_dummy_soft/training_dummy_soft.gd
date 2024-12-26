extends EntityStatable
class_name TrainingDummySoft


## 初始化-定制多个状态
func _init() -> void:
	_add_state(StateIdle.new(self))
	_add_state(StateInvincible.new(self))


## 帧更新前-设置起始状态
func _ready() -> void:
	transform_state("idle")


## 状态切换测试
func _input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		transform_state("idle")
	if event.is_action_released("ui_accept"):
		transform_state("invincible")
	super._input(event)
