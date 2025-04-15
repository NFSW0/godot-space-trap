# 玩家状态栏 玩家加载后触发状态栏一同加载
extends UIBase


@export var health_bar: Label ## 血条
@export var buff_container: VBoxContainer # Buff栏
var ui_requester = null

## UI加载后执行
func on_ui_loaded(requester: Node) -> void:
	if not requester:
		return
	ui_requester = requester
	requester.tree_exited.connect(func():call_deferred("queue_free"))
	if health_bar and health_bar.has_method("on_ui_loaded"): health_bar.on_ui_loaded(requester)
	BuffManager.buff_changed.connect(update_buff)


# Buff 更新函数
func update_buff(active_buff_array: Array[Buff]):
	# 清理旧的 Buff 显示
	for child in buff_container.get_children():
		child.queue_free()
	
	# 筛选出 buff_target 为 self 的 Buff
	if ui_requester == null:
		return
	var filtered_buffs = active_buff_array.filter(func(buff: Buff):
		return buff.buff_target == ui_requester
	)
	
	# 动态创建 Label 节点并显示 Buff 信息
	for buff in filtered_buffs:
		var label = Label.new()
		label.text = format_buff_text(buff)
		buff_container.add_child(label)


# 格式化 Buff 文本
func format_buff_text(buff: Buff) -> String:
	var buff_name = buff.buff_name
	var stack = buff.current_stack
	var duration = roundi(buff.current_duration_remain)  # 剩余时间取整
	return "%s x%s (%ss)" % [buff_name, stack, duration]


func _on_timer_timeout() -> void:
	update_buff(BuffManager.active_buff_array)
