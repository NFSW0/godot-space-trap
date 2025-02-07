extends Entity
class_name Ghost


@export var animation: AnimatedSprite2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		target_environment["move_up"] = true
	if event.is_action_released("move_up"):
		target_environment.erase("move_up")
	if event.is_action_pressed("move_down"):
		target_environment["move_down"] = true
	if event.is_action_released("move_down"):
		target_environment.erase("move_down")
	if event.is_action_pressed("move_left"):
		target_environment["move_left"] = true
	if event.is_action_released("move_left"):
		target_environment.erase("move_left")
	if event.is_action_pressed("move_right"):
		target_environment["move_right"] = true
	if event.is_action_released("move_right"):
		target_environment.erase("move_right")


# 改变环境
func move_up(_delta):
	if animation:
		animation.play("up")
	velocity = speed * Vector2(0, -1)
	move_and_slide()


func move_down(_delta):
	if animation:
		animation.play("down")
	velocity = speed * Vector2(0, 1)
	move_and_slide()


func move_left(_delta):
	if animation:
		animation.play("left")
	velocity = speed * Vector2(-1, 0)
	move_and_slide()


func move_right(_delta):
	if animation:
		animation.play("right")
	velocity = speed * Vector2(1, 0)
	move_and_slide()
