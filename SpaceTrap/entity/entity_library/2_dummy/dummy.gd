## 假人动画(二维变量):静默(Idle)、移动(Move)、受伤(Hurt)、死亡(Dead)
extends InfluenceableEntity2D
#class_name Dummy


@export var animation_tree: AnimationTree ## 动画节点


## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String, reset_on_teleport: bool = true):
	if animation_tree:
		animation_tree.set("parameters/%s/blend_position" % animation_name, velocity.normalized())
		animation_tree.get("parameters/playback").travel(animation_name, reset_on_teleport)


## 执行指令
func _execute_command(command: Dictionary) -> void:
	if command.is_empty():
		travel_animation("Idle")
		return
	for command_type in command:
		match command_type:
			ControllerBase.COMMAND_TYPE.MOVE_TOWARD:
				_move_toward(command[command_type])


## 定向移动
func _move_toward(_direction: Vector2 = Vector2()) -> void:
	direction = _direction
	_move(direction.normalized() * speed)


#region 其他
func _move(final_velocity: Vector2 = Vector2()):
	velocity = final_velocity
	travel_animation("Move")
	move_and_slide()
#endregion 其他
