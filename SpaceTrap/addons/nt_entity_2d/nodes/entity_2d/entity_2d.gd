## 存放实体共有数据
extends CharacterBody2D
class_name Entity2D


@export var entity_id:int = 0

signal mass_changed(new_value: float)
const DEFAULT_MASS = 20
@export var mass:float = DEFAULT_MASS:
	set(value):
		if value != mass:
			value = clamp(value, 0, INF)
			mass_changed.emit(value)
			mass = value
			set("scale", Vector2(value / DEFAULT_MASS, value / DEFAULT_MASS))
