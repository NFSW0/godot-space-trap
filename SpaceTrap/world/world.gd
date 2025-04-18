extends Node2D


func _on_area_2d_body_entered(_body: Node2D) -> void:
	pass


func _on_timer_timeout() -> void:
	# 获取 Area2D 节点
	var area = $Area2D
	
	# 检测 Area2D 中的所有 Body
	var bodies = area.get_overlapping_bodies()
	
	# 遍历每个 Body 并添加 Buff
	for body in bodies:
		# 确保 body 是有效的 Node 对象
		if body is Node:
			# 为 body 添加 ID 为 6 的 Buff
			BuffManager.append_buff(6, body.get_path())
