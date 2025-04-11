shader_type canvas_item;

uniform sampler2D image_multiplier; // 设置透明渐变

void fragment() {
	// 获取 image_multiplier 纹理的亮度作为透明度
	float alpha = texture(image_multiplier, UV).r;

	// 输出最终颜色
	COLOR = vec4(texture(TEXTURE, UV).rgb, alpha);
}
