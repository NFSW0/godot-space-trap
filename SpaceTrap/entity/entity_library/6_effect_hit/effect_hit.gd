extends Node2D
#class_name EffectHit


@export var entity_id:int = 0
@export var particles:GPUParticles2D
@export var area_2d: Area2D


func _ready() -> void:
	particles.restart() # 播放粒子特效


func _on_finished() -> void:
	call_deferred("queue_free")


## 获取在影响范围内的实体
func get_the_entities_in_the_influence_area():
	return area_2d.get_overlapping_bodies()
