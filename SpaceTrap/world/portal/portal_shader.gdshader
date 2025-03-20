shader_type canvas_item;

uniform sampler2D image_multiplier; // 设置透明渐变
uniform sampler2D screen_texture : hint_screen_texture; // 获取屏幕纹理

void fragment() {
	// 获取屏幕纹理颜色
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	
	// 获取 image_multiplier 纹理的亮度作为透明度
	float alpha = texture(image_multiplier, UV).r;
	
	// 输出最终颜色
	COLOR = vec4(screen_color.rgb, alpha);
}
