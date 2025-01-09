class_name Tool


## 比较两个数组是否相同
## 可用于比较复合数据是否相同(需要转换为数组)
static func are_arrays_equal(array1: Array, array2: Array) -> bool:
	# 首先检查数组长度是否相同
	if array1.size() != array2.size():
		return false
	
	# 复制两个数组并进行排序
	var sorted_array1 = array1.duplicate()
	var sorted_array2 = array2.duplicate()
	
	sorted_array1.sort()  # 对第一个数组进行排序
	sorted_array2.sort()  # 对第二个数组进行排序

	# 比较两个排序后的数组是否相同
	return sorted_array1 == sorted_array2
