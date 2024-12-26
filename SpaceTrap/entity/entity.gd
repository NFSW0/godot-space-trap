## 基础实体
## 包含速度和质量(动量体)
## 弹幕、护盾等简单实体:单一状态、简单数据、简单死亡
extends CharacterBody2D
class_name Entity


@export var entity_id:int = 0
@export var direction:Vector2 = Vector2()
@export var speed:float = 0
@export var mass:float = 0


## 更新数据
func update_data(data: Dictionary):
	for key in data:
		set(key, data[key])
