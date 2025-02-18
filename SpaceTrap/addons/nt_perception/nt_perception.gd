## 插件最终目标效果:
## 每个实体附带不均匀的感知区域(函数或黑白强度图决定)，可通过特定Shader渲染出感知区域
## 注册每个实体的区域，四叉树或者八叉树优化处理
@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
