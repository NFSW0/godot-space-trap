shader_type canvas_item;

// 定义一个uniform变量，用于控制剪切功能是否启用。
uniform bool cut_enabled;

// 定义一个uniform变量，用于接收剪切线的坐标。
uniform vec2 cut_line_position;

// 定义一个uniform变量，用于接收剪切线的法线向量。
uniform vec2 cut_line_normal;

// 声明一个varying变量，用于在顶点着色器和片段着色器之间传递世界空间位置。
varying vec4 world_space_position;

// 顶点着色器函数。
void vertex() {
	// 将顶点坐标转换到世界空间，并存储在world_space_position变量中。
	world_space_position = MODEL_MATRIX * vec4(VERTEX, 0, 1);
}

// 片段着色器函数。
void fragment() {
	// 计算从剪切线位置到当前像素位置的向量。
	vec2 line_to_pixel_vector = (cut_line_position - world_space_position.xy);

	// 初始化clip变量，默认值为1.0，表示不裁剪。
	float clip = 1.0;

	// 如果is_cut_enabled为true，则根据法线和剪切线到像素位置的向量计算裁剪。
	if (cut_enabled)
		// 使用点积和步进函数step计算clip值，用于控制裁剪。
		clip = step(dot(line_to_pixel_vector, normalize(cut_line_normal)), 0.0);

	// 设置片段的颜色
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= clip;
}
