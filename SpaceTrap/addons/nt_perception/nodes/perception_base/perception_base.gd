### 基础感知节点(用于继承)
#extends Node
#class_name PerceptionBase
#
#
### 初始化时注册感知节点
#
#
### 销毁时注销感知节点
#
#
#@export var faction: PerceptionManager.Faction = PerceptionManager.Faction.NEUTRAL ## 阵营选择
#@export var detection_range: float = 300.0
#@export var update_interval: float = 0.2
#@export var is_active: bool = true
#
#var _timer: float = 0.0
#var current_targets := {}  # {object_id: PerceptionData}
#
#class PerceptionData:
	#var last_known_position: Vector2
	#var detection_level: float  # 0.0-1.0
	#var last_update_time: float
#
#func _ready() -> void:
	#PerceptionManager.register_node(self)
	##var shape = CollisionShape2D.new()
	##shape.shape = CircleShape2D.new()
	##shape.shape.radius = detection_range
	##add_child(shape)
#
#func _exit_tree() -> void:
	#PerceptionManager.unregister_node(self)
#
#func _process(delta: float) -> void:
	#if _timer <= 0:
		#_timer = update_interval
		#PerceptionManager.update_node(self)  # 由管理器统一调用更新
	#else:
		#_timer -= delta
#
## 更新感知逻辑（由管理器调用）
#func update_perception(nearby_nodes: Array) -> void:
	#for target in nearby_nodes:
		#if target == self: continue
		#if should_detect(target):
			#update_target_data(target)
#
## 子类实现具体检测逻辑
#func should_detect(target: Node) -> bool:
	#return false  # 在子类中实现
#
## 更新目标数据
#func update_target_data(target: Node) -> void:
	#var data = current_targets.get(target.get_instance_id(), PerceptionData.new())
	#data.last_known_position = target.global_position
	#data.detection_level = 1.0  # 可根据需求调整
	#data.last_update_time = Time.get_ticks_msec()
	#current_targets[target.get_instance_id()] = data
	#PerceptionManager.emit_signal("perception_updated", self, target, "detected")
