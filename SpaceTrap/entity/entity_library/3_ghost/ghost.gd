## 鬼魂动画(二维变量):移动&静默(Move)
extends InfluenceableEntity2D
#class_name Ghost


@export var animation_tree: AnimationTree ## 动画节点


## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String):
	if animation_tree:
		animation_tree.get("parameters/playback").travel(animation_name)


## 执行指令
func _execute_command(command: Dictionary) -> void:
	for command_type in command:
		match command_type:
			ControllerBase.COMMAND_TYPE.MOVE_TOWARD:
				_move_toward(command[command_type])


## 定向移动
func _move_toward(_direction: Vector2 = Vector2()) -> void:
	direction = _direction
	travel_animation("Move")
	animation_tree.set("parameters/Move/blend_position", direction)
	velocity = direction * speed
	move_and_slide()
