shader_type canvas_item;

uniform sampler2D tex;

void fragment() {
	vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;

	vec4 texColor = texture(tex, uv);

	COLOR = texColor;
}