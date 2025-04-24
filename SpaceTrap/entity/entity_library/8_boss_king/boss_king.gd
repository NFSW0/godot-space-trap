## 首领-君王
#class_name King
extends ControllableEntity2D


var attack_range : float = 50 ## 攻击距离


func _ready() -> void:
	mass_changed.connect(_on_mass_changed) # 连接信号
	_set_brain()


#region 质量(生命)
var old_health : float = 0.0
## 处理质量变化
func _on_mass_changed(new_health : float) -> void:
	if new_health < 0.01:
		_death()
		return
	#set("scale", Vector2(new_health / DEFAULT_MASS, new_health / DEFAULT_MASS))
	old_health = new_health
## 死亡
func _death():
	controllable = false
	travel_animation("Dead")
	animation_tree.get("parameters/playback").start("Dead", true)
#endregion 质量(生命)


#region 动画
@export var animation_tree: AnimationTree ## 动画节点
## 过渡到另一个动画 传入动画名称
func travel_animation(animation_name: String, reset_on_teleport: bool = true):
	if animation_tree:
		animation_tree.set("parameters/%s/blend_position" % animation_name, velocity.normalized().x)
		animation_tree.get("parameters/playback").travel(animation_name, reset_on_teleport)
#endregion 动画



#region 智能-决策
func _set_brain():
	var ai_brain = GOAP_AIBrain.new()
	# 设置世界状态更新方法
	ai_brain.world_update = _update_local_state
	# 添加目标(不同对象可以有不同目标)
	ai_brain.current_goals.append(
		GOAP_AIBrain.GOAPGoal.new(
			"AttackTarget",
			90.0,
			{"target_destroyed": true}
		)
	)
	# 添加行动
	ai_brain.available_actions.append(
		GOAP_AIBrain.GOAPAction.new(
			"MoveToTarget",
			{"target_position": func(v): return position.distance_to(v) > attack_range if v else false},
			{"target_in_range": true},
			1.0,
			func (state): return {ControllerBase.COMMAND_TYPE.MOVE_TO: state["target"].get("position")}
		)
	)
	ai_brain.available_actions.append(
		GOAP_AIBrain.GOAPAction.new(
			"AttackTarget",
			{"target_in_range": true},
			{"target_destroyed": true},
			2.0,
			func(state): return {ControllerBase.COMMAND_TYPE.ATTACK: state["target"].get("position")}
		)
	)
	ai_brain.available_actions.append(
		GOAP_AIBrain.GOAPAction.new(
			"AttackTarget2",
			{"can_attack2": true},
			{"target_destroyed": true},
			2.0,
			func(state): return {"Attack2": state["target"].get("position")}
		)
	)
	controller.set("ai_brain", ai_brain)


# 更新本地状态条件
func _update_local_state() -> Dictionary:
	var local_state = {}
	
	var target = _perceptual()
	if not target: return local_state
	local_state["target"] = target
	
	var target_position = target.get("position")
	if not target_position: return local_state
	local_state["target_position"] = target_position
	
	var target_in_range = position.distance_to(target_position) < attack_range
	local_state["target_in_range"] = target_in_range
	
	local_state["can_attack1"] = can_attacking
	
	local_state["can_attack2"] = can_attacking2
	
	return local_state
#endregion 智能-决策


#region 智能-感知
@export var perceptron: Area2D ## 感知节点
# 感知(用于确定行动目标)
func _perceptual() -> Node:
	if has_foced:
		# 获取属于 "Player" 组的所有节点
		var player_nodes = get_tree().get_nodes_in_group("Player")
		# 检查数组是否非空
		if player_nodes.size() > 0:
			return player_nodes[0]
	var nodes_in_area = perceptron.get_overlapping_areas() + perceptron.get_overlapping_bodies()
	# 排除无关对象
	nodes_in_area = nodes_in_area.filter(func(element): return element.is_in_group("Player"))
	if nodes_in_area.is_empty():
		return null
	nodes_in_area.sort_custom(_compare_priority)
	return nodes_in_area[0]
# 排序
func _compare_priority(a: Node, b: Node) -> int:
	# 近距离优先
	var dist_a = position.distance_to(a.position)
	var dist_b = position.distance_to(b.position)
	return dist_a < dist_b
#endregion 智能-感知



#region 行动中心
## 执行行动指令
## 遍历传入的指令字典，并根据指令类型执行相应的行动
func _execute_command(command: Dictionary) -> void:
	if command.is_empty():
		travel_animation("Idle")
		return
	for command_type in command:
		match command_type:
			ControllerBase.COMMAND_TYPE.MOVE_TO:
				_move_to(command[command_type])
			ControllerBase.COMMAND_TYPE.MOVE_TOWARD:
				_move_toward(command[command_type])
			ControllerBase.COMMAND_TYPE.ATTACK:
				_attack(command[command_type])
			"Attack2":
				_attack2(command[command_type])

## 定点移动
## 通过导航代理计算路径并移动至指定位置
func _move_to(data: Vector2 = Vector2()) -> void:
	if navigation_agent_2d:
		var map_rid = navigation_agent_2d.get_navigation_map()
		navigation_agent_2d.target_position = data
		# 已更新寻路且未抵达最终位置
		if NavigationServer2D.map_get_iteration_id(map_rid) and not navigation_agent_2d.is_navigation_finished():
			var next_path_position:Vector2 = navigation_agent_2d.get_next_path_position()
			navigation_agent_2d.set_velocity((next_path_position - position).normalized() * speed)
			# 避障计算独立进行，因此在信号方法直接设置速度会导致不断移动
			if velocity_move_to:
				_move(velocity_move_to)

## 定向移动
## 直接朝指定方向移动，不依赖导航系统
func _move_toward(_direction: Vector2 = Vector2()) -> void:
	_move(_direction.normalized() * speed)

## 攻击
## 若可攻击，则进入攻击状态，并设置冷却时间
func _attack(data: Vector2 = Vector2())-> void:
	if not can_attacking:
		return
	can_attacking = false
	get_tree().create_timer(attack_cooldown).connect("timeout", func():can_attacking = true)
	attack_position = data if data else get_global_mouse_position()
	controllable = false
	travel_animation("Attack1") # 动画帧中设置可控状态 - 攻击动画中处于失控状态
	animation_tree.get("parameters/playback").start("Attack1", true)
	await animation_tree.animation_finished
	controllable = true

func _attack2(data: Vector2= Vector2()):
	if not can_attacking2:
		return
	can_attacking2 = false
	get_tree().create_timer(attack_cooldown * 10).connect("timeout", func():can_attacking2 = true)
	attack_position = data if data else get_global_mouse_position()
	controllable = false
	travel_animation("Attack2") # 动画帧中设置可控状态 - 攻击动画中处于失控状态
	animation_tree.get("parameters/playback").start("Attack2", true)
	await animation_tree.animation_finished
	controllable = true
#endregion 行动中心


#region 行动附属-攻击
var attack_position = position ## 进攻坐标
var attack_cooldown = 1.0  ## 攻击冷却时间（秒）
var can_attacking = true ## 是否可以进行攻击
var can_attacking2 = true ## 是否可以进行攻击
var penetration:int = 0 ## 穿透数，可命中多个目标时，最多命中 [穿透数] 个目标，<=0 表示无限
var damage = 10 ## 伤害值

## 动画帧回调方法
## 生成实体（如投射物）并赋予其初始速度
func animation_attack1():
	var bodies = $HitArea1.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			body.mass -= 5

func animation_attack2():
	var bodies = $HitArea2.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			body.mass -= 10

func animation_attack3():
	var bodies = $HitArea3.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			body.mass -= 15

func animation_attack4():
	var bodies = $HitArea4.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			body.mass -= 10
	EntityManager.generate_entity_immediately({"entity_id": 9, "position": get_tree().get_nodes_in_group("Player")[0].position})
	# 在周围生成3只骷髅
	var num_skeletons = 3  # 骷髅数量
	var radius = 50.0  # 骷髅生成的半径范围
	for i in range(num_skeletons):
		# 计算一个随机角度，用于分布骷髅
		var angle = randf_range(0, 2 * PI)
		# 根据角度和半径计算偏移位置
		var offset = Vector2(radius * cos(angle), radius * sin(angle))
		# 计算骷髅的生成位置
		var skeleton_position = position + offset
		# 生成骷髅实体
		EntityManager.generate_entity_immediately({"entity_id": 5, "position": skeleton_position, "attacker": get_tree().get_nodes_in_group("Player")[0]})

## 命中回调方法（接收所有碰撞信息，按距离排序）
func process_collisions(bullet: Node, collisions: Array):
	var max_hits = penetration if penetration > 0 else collisions.size()
	var hits = 0
	for collision in collisions:
		if hits >= max_hits:
			break
		var collider = collision["collider"] # 额外参数包括: point, distance, normal
		# 排除自己
		if collider == self:
			continue
		# 处理碰撞（包括伤害）
		var hitData = HitData.new(bullet.get_path(), collider.get_path(), collision["normal"])
		HitManager.append_hit_event(hitData.serialize())
		# 添加击退效果
		var buff_manager = get_node_or_null("/root/BuffManager")
		if buff_manager:
			buff_manager.append_buff(3, collider.get_path(), {"knockback_velocity":(attack_position - position).normalized() * damage})
		hits += 1
#endregion 行动附属-攻击


#region 行动附属-移动
@export var speed:float = 50 ## 移动速度
@export var navigation_agent_2d: NavigationAgent2D ## 导航代理节点
var velocity_move_to: Vector2 = Vector2() ## 经过避障计算后的移动速度

## 统一移动逻辑，调用 move_and_slide 进行物理移动
func _move(final_velocity: Vector2 = Vector2()):
	velocity = final_velocity
	travel_animation("Move")
	move_and_slide()

## 导航避障更新回调
## 计算安全速度，避免碰撞
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity_move_to = safe_velocity
#endregion 行动附属-移动


# 定义变量
@export var focus_duration: float = 0.5  # 聚焦动画持续时间
@export var zoom_scale: float = 1.5      # 放大倍数
@export var time_scale: float = 0.5     # 游戏时间减速比例
var original_position: Vector2          # 原始摄像机位置
var original_zoom: float                # 原始摄像机缩放
var camera: Camera2D                    # 当前摄像机
var tween: Tween                        # Tween 节点
var has_foced : bool = false
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if has_foced:
		return
	
	if not camera:
		camera = get_viewport().get_camera_2d()
		if not camera:
			print("未找到 Camera2D，请确保场景中有一个活动的 Camera2D")
			return
	if not tween:
		tween = camera.create_tween()
	has_foced = true
	UIManager.open_ui("boss_status", self)
	mass_changed.emit(mass)
	# 保存原始摄像机状态
	if original_position == null:
		original_position = camera.position
		original_zoom = camera.get("zoom")
	# 减速游戏时间
	Engine.time_scale = time_scale
	AudioManager.stop_bgm()
	$AudioStreamPlayer2D.play()
	# 创建聚焦动画
	tween = create_tween()
	# 设置目标位置和缩放
	var target_position = global_position  # BOSS 的全局位置
	var target_zoom = Vector2.ONE * zoom_scale
	# 添加动画：移动到目标位置
	tween.tween_property(camera, "global_position", target_position, focus_duration)
	# 添加动画：放大摄像机
	tween.tween_property(camera, "zoom", target_zoom, focus_duration)
	# 添加回调：播放 BOSS 的动画
	tween.chain().tween_callback(_play_boss_animation)
	# 添加停顿：暂停 1 秒
	tween.tween_interval(2.0)
	# 添加回调：恢复原始状态
	tween.chain().tween_callback(_restore_camera_state)


func _play_boss_animation() -> void:
	travel_animation("Idle")
	animation_tree.get("parameters/playback").start("Idle", true)


func _restore_camera_state() -> void:
	if not camera or not tween:
		return
	# 恢复游戏时间
	Engine.time_scale = 1.0
	# 创建恢复动画
	tween = camera.create_tween()
	# 添加动画：恢复原始位置
	tween.tween_property(camera, "position", original_position, focus_duration)
	# 添加动画：恢复原始缩放
	tween.tween_property(camera, "zoom", Vector2.ONE, focus_duration)
	controllable = true
