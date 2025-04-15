extends Buff
class_name BuffBleeding

## 附益更新逻辑
func _physics_process(delta: float):
	# 持续时间更新
	current_duration_remain -= delta
	# 间歇时间更新
	if buff_tick_interval > 0:
		if current_tick_remain > 0:
			current_tick_remain -= delta
		else:
			current_tick_count += 1
			current_tick_remain = buff_tick_interval
			var target_mass = buff_target.get("mass")
			if target_mass:
				buff_target.set("mass", target_mass - current_stack * 3)
