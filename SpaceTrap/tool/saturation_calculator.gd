## 饱和计算器: Y随X的增长而减速增长且不超过最大值
class_name SaturationCalculator

var ref_x: float  ## 参考 X 值(标准参数)
var ref_y: float  ## 当 X 为 ref_x 时的目标 Y 值(标准结果)
var max_y: float  ## Y 的最大值
var alpha: float  ## 增长率

## 构造函数，初始化计算参数
## @param ref_x 参考 X 值
## @param ref_y 当 X 为 ref_x 时的目标 Y 值
## @param max_y Y 的最大值
func _init(_ref_x: float, _ref_y: float, _max_y: float) -> void:
	ref_x = _ref_x
	ref_y = _ref_y
	max_y = _max_y
	alpha = -log(1.0 - _ref_y / _max_y) / _ref_x

## 计算给定 x 对应的 y 值
func calculate(x: float) -> float:
	return max_y * (1.0 - exp(-alpha * x))
