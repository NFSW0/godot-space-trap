extends Node2D


@export var targe_portal:Node


func _on_area_2d_body_entered(body: Node2D) -> void:
	# 传递body、self、target_portal给处理器
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	# 传递area、self、target_portal给处理器
	pass # Replace with function body.
