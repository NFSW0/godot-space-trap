## 玩家控制体
## 检测并响应输入实现玩家对实体的控制
## 检测移动设备添加控制UI
extends Node
class_name _ControllerPlayer


var target:EntityStatable = null ## 控制对象


func set_target(_target:EntityStatable):
	target = _target


## 互动
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		pass


## 移动
func _process(delta: float) -> void:
	if not target:
		return
	
	target.set("direction", _get_movement_vector().normalized())


## 获取移动方向
func _get_movement_vector() -> Vector2:
	if multiplayer.has_multiplayer_peer():
		if not is_multiplayer_authority():
			return Vector2()
	var x_movement:float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement:float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)
