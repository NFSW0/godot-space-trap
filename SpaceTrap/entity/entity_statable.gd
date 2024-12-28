## 状态化实体基础类
## 包含额外数据(如生命值、装备等)和多状态处理(静默、移动、攻击、死亡等)
## 玩家、敌人等复杂实体:多状态、多数据、额外死亡处理
extends CharacterBody2D
class_name EntityStatable


@export var entity_id:int = 0
@export var direction:Vector2 = Vector2()
@export var speed:float = 0
@export var mass:float = 1


# 额外数据
var state_library = {} # 状态库
var current_state:State # 当前状态


## 初始化-定制多个状态
func _init() -> void:
	pass


## 帧更新前-设置起始状态
func _ready() -> void:
	pass


#region 更新当前状态
func _input(event: InputEvent) -> void:
	if current_state and current_state.has_method("_input"):
		current_state._input(event)
func _unhandled_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("_unhandled_input"):
		current_state._unhandled_input(event)
func _unhandled_key_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("_unhandled_key_input"):
		current_state._unhandled_key_input(event)
func _process(delta: float) -> void:
	if current_state and current_state.has_method("_process"):
		current_state._process(delta)
func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("_physics_process"):
		current_state._physics_process(delta)
#endregion


#region 转变状态
func transform_state(new_state_name):
	# 允许重复状态-比如连续击退(如果击退状态没有无敌帧)
	# 如果状态进出的方法涉及`await`关键字，则可以把这里的`await`反注释
	if current_state:
		current_state.exit_state()
		#await current_state.exited
	var new_state:State = state_library[new_state_name]
	new_state.enter_state()
	#await new_state.entered
	current_state = new_state
#endregion


#region 添加状态
func _add_state(new_state:State):
	if state_library.has(new_state.state_name):
		return
	state_library[new_state.state_name] = new_state
#endregion
