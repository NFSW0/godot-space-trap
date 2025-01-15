class_name Tool


## 比较两个数组是否相同
## 可用于比较复合数据是否相同(需要转换为数组)
static func are_arrays_equal(array1: Array, array2: Array) -> bool:
	# 首先检查数组长度是否相同
	if array1.size() != array2.size():
		return false
	
	# 将 NodePath 转换为字符串，确保可比较性
	var sorted_array1 = array1.map(func(element): return element if typeof(element) != TYPE_NODE_PATH else String(element)).duplicate()
	var sorted_array2 = array2.map(func(element): return element if typeof(element) != TYPE_NODE_PATH else String(element)).duplicate()
	
	# 对两个数组进行排序
	sorted_array1.sort()
	sorted_array2.sort()
	
	# 比较两个排序后的数组是否相同
	return sorted_array1 == sorted_array2
