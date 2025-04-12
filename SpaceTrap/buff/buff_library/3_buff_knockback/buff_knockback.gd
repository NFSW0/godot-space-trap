## 击退附益:
## 间歇时:以一定速度缓慢停止
extends Buff
class_name BuffKnockback


@export var knockback_velocity: Vector2 = Vector2()


## 附益叠层逻辑
func stackable(existing_buff_array:Array[Buff]) -> bool:
	# 清除对应目标的调试附益
	for buff in existing_buff_array:
		if buff.buff_target == buff_target and buff.buff_id == 4:
			return true
	return super.stackable(existing_buff_array)

## 附益添加
func start():
	if buff_target:
		buff_target.set("controllable", false)
	else:
		current_duration_remain = 0


## 附益更新
func _physics_process(delta: float):
	current_duration_remain -= delta
	
	if buff_target and buff_target is CharacterBody2D:
		buff_target.velocity = knockback_velocity * current_duration_remain if current_duration_remain < 1 else knockback_velocity
		buff_target.move_and_slide()
	else:
		current_duration_remain = 0


## 附益结束, 传入已有附益
func end(_existing_buff_array:Array[Buff]):
	if buff_target:
		buff_target.set("controllable", true)
	else:
		current_duration_remain = 0
