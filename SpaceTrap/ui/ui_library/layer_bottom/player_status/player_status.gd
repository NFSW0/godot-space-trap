extends Control


@export var health_bar: Label ## 生命值显示
@export var health_base: float ## 血条长度计算底数:


func update_health_bar(health: float):
	health_bar.size.x = calculate_health_bar_length(health)
	health_bar.text = "%s" % roundi(health)


func calculate_health_bar_length(health: float) -> float:
	var k: float = 21.67 ## 100HP对应100px, 缓速增长长度最大不超过480px
	return k * log(1 + health)


# 调试方法：计算 k 值 (标准血量, 标准长度, 最大长度)
func calculate_k(base_health: float, base_length: float, max_length: float) -> float:
	# 计算 k 值
	var k := base_length / log(1 + base_health)
	
	# 输出调试信息
	print("计算的 k 值: ", k)
	print("验证最大长度 (H -> ∞): ", k * log(1 + 1e9))  # 模拟 H 趋近无穷
	
	# 检查 k 是否合理（可选）
	if k * log(1 + 1e9) > max_length:
		push_warning("警告: k 值可能导致血条长度超过最大长度！")
	
	return k
