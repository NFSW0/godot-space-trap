## 击退附益:
## 间歇时:以一定速度缓慢停止
extends Buff
class_name BuffKnockback


@export var knockback_velocity: Vector2 = Vector2()


## 附益更新
func _physics_process(delta: float):
	current_duration_remain -= delta
	
	if buff_target is CharacterBody2D:
		buff_target.velocity = knockback_velocity * current_duration_remain if current_duration_remain < 1 else knockback_velocity
		buff_target.move_and_slide()
