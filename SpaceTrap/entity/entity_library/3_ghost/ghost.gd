## 鬼魂动画(二维变量):移动&静默(Move)
extends ControllableEntity2D
#class_name Ghost


@export var animation_tree: AnimationTree ## 动画节点


#region 动画
## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String, reset_on_teleport: bool = true):
	if animation_tree:
		animation_tree.set("parameters/%s/blend_position" % animation_name, velocity.normalized())
		animation_tree.get("parameters/playback").travel(animation_name, reset_on_teleport)
#endregion 动画

#region 行动
## 执行指令
func _execute_command(command: Dictionary) -> void:
	for command_type in command:
		match command_type:
			ControllerBase.COMMAND_TYPE.MOVE_TOWARD:
				_move_toward(command[command_type])


## 定向移动
@export var speed:float = 100
func _move_toward(_direction: Vector2 = Vector2()) -> void:
	_move(_direction.normalized() * speed)
#endregion 行动

#region 其他
func _move(final_velocity: Vector2 = Vector2()):
	velocity = final_velocity
	travel_animation("Move")
	move_and_slide()
#endregion 其他
