## 骷髅动画(二维变量):静默(Idle)、移动(Move)、受伤(Hurt)、死亡(Dead)
extends InfluenceableEntity2D
#class_name Skeleton


@export var animation_tree: AnimationTree ## 动画节点
@export var navigation_agent_2d: NavigationAgent2D ## 导航节点


## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String):
	if animation_tree:
		animation_tree.get("parameters/playback").travel(animation_name)


## 执行行动指令
func _execute_command(command: Dictionary) -> void:
	for command_type:ControllerBase.COMMAND_TYPE in command:
		match command_type:
			ControllerBase.COMMAND_TYPE.MOVE_TO:
				_move_to(command[command_type])
			ControllerBase.COMMAND_TYPE.ATTACK:
				_attack(command[command_type])


## 感知到实体时触发(用于发现行动目标并决策行动计划)
func _on_perceived_target(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# 通知AI发现目标
		pass


## 定点移动
func _move_to(data: Vector2 = Vector2()) -> void:
	navigation_agent_2d.target_position = data
	var next_path_position:Vector2 = navigation_agent_2d.get_next_path_position()
	velocity = (next_path_position - position).normalized() * speed
	move_and_slide()


## 攻击
func _attack(data = null)-> void:
	print("骷髅发动攻击")
