shader_type canvas_item;

uniform vec2 line_start; // 线的起点（屏幕坐标）
uniform vec2 line_end;   // 线的终点（屏幕坐标）

void fragment() {
    // 获取当前像素的屏幕坐标
    vec2 p = FRAGCOORD.xy;

    // 计算直线的法向量
    vec2 line_dir = normalize(line_end - line_start);
    vec2 normal = vec2(-line_dir.y, line_dir.x);  // 计算垂直的法向量

    // 计算当前像素点到线的方向
    vec2 point_to_line = p - line_start;

    // 计算当前像素点相对于线的位置
    float side = dot(point_to_line, normal);

    // 如果当前像素点在线的一侧，则隐藏它
    if (side < 0.0) {
        discard; // 丢弃当前像素，不渲染
    }

    // 如果当前像素点在线的另一侧，则渲染
    COLOR = texture(TEXTURE, UV);
}
