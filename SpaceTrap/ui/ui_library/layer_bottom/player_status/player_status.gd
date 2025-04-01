# 玩家状态栏 玩家加载后触发状态栏一同加载
extends UIBottom


## UI加载后执行
func on_ui_loaded(requester: Node) -> void:
	if not requester:
		return
	requester.tree_exited.connect(func():call_deferred("queue_free"))
	if health_bar and health_bar.has_method("on_ui_loaded"): health_bar.on_ui_loaded(requester)


@export var health_bar: Label ## 血条
