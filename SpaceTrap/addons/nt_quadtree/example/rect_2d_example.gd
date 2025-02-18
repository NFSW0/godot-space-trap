extends Node2D

@onready var color_rect: ColorRect = $ColorRect

func get_global_rect2():
	return Rect2(color_rect.global_position, color_rect.size)
