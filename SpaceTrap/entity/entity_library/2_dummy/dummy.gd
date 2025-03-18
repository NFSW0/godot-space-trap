## 假人动画(二维变量):静默(Idle)、移动(Move)、受伤(Hurt)、死亡(Dead)
extends InfluenceableEntity2D
#class_name Dummy


@export var animation_tree: AnimationTree ## 动画节点


func _ready() -> void:
	_connect_health_signal()


#region 生命
signal health_changed(old_value: float, new_value: float, max_health: float)
@export var health_max: float = 20.0:
	set(value):
		if value != health_max:
			value = clamp(value, 0, INF)
			health_changed.emit(health_old, health_current, value)
			health_max = value
@export var health_current: float = 20.0:
	set(value):
		if value != health_current:
			value = clamp(value, 0, health_max)
			health_changed.emit(health_old, value, health_max)
			health_old = health_current
			health_current = value
var health_old: float = 20.0
func take_damage(damage):
	health_current -= damage
	if not health_current > 0:
		return
	travel_animation("Hurt")
	var buff_manager = get_node_or_null("/root/BuffManager")
	if buff_manager:
		buff_manager.append_buff(3, get_path(), {"knockback_velocity":velocity * -1})
func _connect_health_signal(node:Node = self):
	node.connect("health_changed", _on_health_changed)
func _on_health_changed(_old_value: float, new_value: float, max_health: float):
	if new_value <= 0 or max_health <= 0:
		_death()
		return
## 死亡
func _death():
	controllable = false
	remove_from_group("Player")
	travel_animation("Dead")
	animation_tree.get("parameters/playback").start("Dead", true)
#endregion 生命


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
	if command.is_empty():
		travel_animation("Idle")
		return
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
