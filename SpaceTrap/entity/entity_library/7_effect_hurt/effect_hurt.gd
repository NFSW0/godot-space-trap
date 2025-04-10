extends GPUParticles2D
#class_name EffectHurt

@export var entity_id:int = 0


func _ready() -> void:
	restart()
	$AudioStreamPlayer2D.play()

func _on_finished() -> void:
	call_deferred("queue_free")
