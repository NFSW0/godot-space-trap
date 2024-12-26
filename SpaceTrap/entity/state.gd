## 状态基础类: 无状态名称，不应直接new这个类
## 包含构建状态、进入状态、更新状态、退出状态
## 约定动画名与状态名相同，方便自动切换状态
## _process(delta: float)
## _physics_process(delta: float)
extends Resource
class_name State


signal entered
signal exited
var _entity:EntityStatable


## 构建状态
func _init(target_entity: EntityStatable) -> void:
	_entity = target_entity


## 进入状态
func enter_state():
	entered.emit()


## 更新状态
func _input(_event: InputEvent) -> void:
	pass
## 更新状态
func _unhandled_input(_event: InputEvent) -> void:
	pass
## 更新状态
func _unhandled_key_input(_event: InputEvent) -> void:
	pass
## 更新状态
func _process(_delta: float) -> void:
	pass
## 更新状态
func _physics_process(_delta: float) -> void:
	pass


## 退出状态
func exit_state():
	exited.emit()
