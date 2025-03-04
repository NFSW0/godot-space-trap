## 调试附益:
## 添加时:在控制台输出附益信息
## 输入时:在控制台输出松开的按键
## 间歇时:每1秒在控制台输出附益信息
## 结束时:在控制台输出附益信息
extends Buff
class_name BuffDebug


## 附益添加逻辑
func start():
	print("调试开始")


## 附益输入监听逻辑
func _input(event: InputEvent) -> void:
	if event.is_released() and not event is InputEventMouseMotion:
		print("调试输入:", event.as_text())


## 附益更新逻辑
func _physics_process(delta: float):
	current_duration_remain -= delta
	if buff_tick_interval > 0:
		if current_tick_remain > 0:
			current_tick_remain -= delta
		else:
			current_tick_count += 1
			current_tick_remain = buff_tick_interval
			print("=================================")
			print("编号:", buff_id)
			print("标签:", buff_tags)
			print("最大叠层:", buff_max_stack)
			print("最大持续时间:", buff_max_duration)
			print("永久:", buff_permanent)
			print("间歇时间:", buff_tick_interval)
			print("-叠层:", current_stack)
			print("-间歇:", current_tick_count)
			print("-剩余的间歇时间:", current_tick_remain)
			print("-剩余的持续时间:", current_duration_remain)
			print("=================================")


## 附益消除逻辑, 传入已有附益, 用于影响自身数据
func end(existing_buff_array:Array[Buff]):
	var buff_id_array = []
	for buff in existing_buff_array:
		buff_id_array.append(buff.buff_id)
	print("调试结束", buff_id_array)
