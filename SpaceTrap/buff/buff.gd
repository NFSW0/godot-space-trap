## 附益
## 导出为资源文件存放在附益库中
extends Resource
class_name Buff


@export var buff_id:int = 0 ## 附益编号
@export var buff_tags:Array[int] = [] ## 附益标签代号 代号含义由策划数据定
@export var buff_max_stack:int = 1 ## 附益最大叠层
@export var buff_max_duration:float = 300 ## 附益最大持续时间
@export var buff_permanent:bool = false ## 是否永久
@export var buff_tick_interval:float = 0.2 ## 附益间歇时间
@export var current_stack:int = 1 ## 当前附益叠层
@export var current_tick_count:int = 0 ## 当前附益已间歇次数
@export var current_tick_remain:float = 0.2 ## 当前附益剩余的间歇时间
@export var current_duration_remain:float = 10 ## 当前附益剩余的持续时间


var buff_target:Node = null ## 附益目标
var buff_source:Node = null ## 附益来源


## 新建附益(从附益库中复制并调整数据)
func new(_buff_target:Node, config_data:Dictionary = {}) -> Buff:
	var new_buff = self.duplicate(true)
	new_buff.buff_target = _buff_target
	for key in config_data.keys():
		new_buff.set(key,config_data[key])
	return new_buff


## 附益叠层逻辑, 在附益添加前调用, 传入目标对象已有的附益集
## 可用于影响自身数据
## true  -已叠层, 忽略当前附益的添加请求
## false -未叠层, 当前附益添加为新附益
## 默认情况:
## 同目标 & 同附益 & 同来源: 叠层相加(不超过最大值), 持续时间相加(不超过最大值)
func stackable(existing_buff_array:Array[Buff]) -> bool:
	for buff in existing_buff_array:
		if buff.buff_id == buff_id and buff.buff_source == buff_source and buff.buff_target == buff_target:
			buff.current_stack = min(buff.current_stack + current_stack, buff_max_stack)
			buff.current_duration_remain = min(buff.current_duration_remain + current_duration_remain, buff_max_duration)
			return true
	return false


## 附益添加逻辑
func start():
	pass


## 附益输入监听逻辑
func _input(_event: InputEvent) -> void:
	pass


## 附益更新逻辑
func _physics_process(_delta: float):
	pass
	## 持续时间更新
	#current_duration_remain -= delta
	## 间歇时间更新
	#if buff_tick_interval > 0:
		#if current_tick_remain > 0:
			#current_tick_remain -= delta
		#else:
			#current_tick_count += 1
			#current_tick_remain = buff_tick_interval


## 附益消除逻辑, 传入已有附益, 可用于影响自身数据
func end(_existing_buff_array:Array[Buff]):
	pass
