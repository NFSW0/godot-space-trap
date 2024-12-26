## 幸运附益:
## 添加时:清除调试附益, 运气+1
## 结束时:运气-1
extends Buff
class_name BuffLuckIncrease

## 附益叠层逻辑
func stackable(existing_buff_array:Array[Buff]) -> bool:
	for buff in existing_buff_array:
		if buff.buff_target == buff_target and buff.buff_id == 1:
			buff.current_duration_remain = 0
	return super.stackable(existing_buff_array)


## 附益添加逻辑, 传入已有附益, 用于影响自身数据
func start():
	print("运气+1")

## 附益更新
func _physics_process(delta: float):
	current_duration_remain -= delta
	if buff_tick_interval > 0:
		if current_tick_remain > 0:
			current_tick_remain -= delta
		else:
			current_tick_count += 1
			current_tick_remain = buff_tick_interval

## 附益消除逻辑, 传入已有附益, 用于影响自身数据
func end(_existing_buff_array:Array[Buff]):
	print("运气-1")
