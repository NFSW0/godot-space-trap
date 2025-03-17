## 存放实体共有数据
extends CharacterBody2D
class_name Entity2D


@export var entity_id:int = 0
@export var direction:Vector2 = Vector2()
@export var speed:float = 0
@export var mass:float = 1:
	set(value):
		mass = value
		set("scale", Vector2(value / 1, value / 1))
		if mass < 0.1:
			call_deferred("queue_free")
