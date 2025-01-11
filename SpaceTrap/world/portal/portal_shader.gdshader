shader_type canvas_item;

uniform bool gray_enabled = false;

void fragment() {
	if (gray_enabled) {
		// 获取原始屏幕纹理的颜色
		vec4 tex_color = texture(TEXTURE, UV);
		// 计算灰度值
		float gray = dot(tex_color.rgb, vec3(0.2999, 0.5870, 0.1140));
		// 输出灰度颜色
		COLOR = vec4(vec3(gray), 1.0);
	}
}
