## 2D平面移动
extends BehaviorBase
class_name BehaviorMove2D


@export var max_speed_name: String = "max_speed"
@export var animation_name_move_up: String = "move_up"
@export var animation_name_move_down: String = "move_down"
@export var animation_name_move_left: String = "move_left"
@export var animation_name_move_right: String = "move_right"


## 执行行动
func execute(delta: float, entity: ControllableEntity2D) -> int:
	# 获取输入的运动矢量
	var movement_vector = _get_movement_vector(entity.get(max_speed_name))
	if movement_vector != Vector2.ZERO:
		entity.velocity = movement_vector
		entity.move_and_slide()
		# 根据移动方向播放相应的动画
		_play_animation_based_on_direction(movement_vector, entity)
		return Status.SUCCESS
	# 如果没有输入，则返回失败状态
	return Status.FAILURE


## 获取输入的运动矢量
func _get_movement_vector(max_speed:float) -> Vector2:
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	return input_direction.normalized() * input_direction.length() * max_speed


## 根据移动方向播放相应的动画
func _play_animation_based_on_direction(direction: Vector2, entity: ControllableEntity2D):
	# 判断主要移动方向
	if abs(direction.x) > abs(direction.y):
		# 水平移动优先
		if direction.x > 0:
			entity.travel_animation(animation_name_move_right)
		else:
			entity.travel_animation(animation_name_move_left)
	else:
		# 垂直移动优先
		if direction.y > 0:
			entity.travel_animation(animation_name_move_down)
		else:
			entity.travel_animation(animation_name_move_up)
