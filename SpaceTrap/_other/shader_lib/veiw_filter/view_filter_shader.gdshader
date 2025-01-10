shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	// 获取原始屏幕纹理的颜色
	vec4 color = texture(screen_texture, SCREEN_UV);

	// 计算灰度值
	float gray = dot(color.rgb, vec3(0.2999, 0.5870, 0.1140));

	// 输出灰度颜色
	COLOR = vec4(vec3(gray), 1.0);
}
