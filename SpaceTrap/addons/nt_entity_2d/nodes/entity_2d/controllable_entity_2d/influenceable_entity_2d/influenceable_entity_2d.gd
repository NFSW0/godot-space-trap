## 可被影响的实体 TODO 准备改成通用执行逻辑 所有影响效果由Buff实现
extends ControllableEntity2D
class_name InfluenceableEntity2D


@export var invincible_time_factor: float = 1.0 ## 无敌时间倍率系数
var invincible: bool = false ## 是否无敌


## 产生影响 influence(self)方法应接收InfluenceableEntity2D参数
func do_influence(influence: Callable, invincible_time: float = 0.5):
	if invincible:
		return
	if invincible_time > 0:
		_do_invincible(invincible_time_factor * invincible_time)
	influence.call(self)


## 开启无敌 传入无敌时长
func _do_invincible(time_sec: float):
	invincible = true
	await get_tree().create_timer(time_sec).timeout
	invincible = false
