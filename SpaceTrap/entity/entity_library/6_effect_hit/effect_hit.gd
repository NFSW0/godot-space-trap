extends Node2D
#class_name EffectHit


@export var entity_id:int = 0
@export var particles:GPUParticles2D


func _ready() -> void:
	particles.restart() # 播放粒子特效


func _on_finished() -> void:
	call_deferred("queue_free")


## 近战攻击获取伤害区域
func get_range():
	pass
