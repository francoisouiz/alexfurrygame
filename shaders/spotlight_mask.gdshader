shader_type canvas_item;

uniform vec2 center_position = vec2(0.5, 0.5);
uniform vec2 hole_size = vec2(0.1, 0.1); 
uniform float corner_radius = 0.02;
uniform float feather = 0.005;
uniform vec4 overlay_color : source_color = vec4(0.0, 0.0, 0.0, 0.85);

float sdf_box(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
}

void fragment() {
    vec2 aspect_ratio = vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
    vec2 uv = SCREEN_UV * aspect_ratio;
    vec2 center = center_position * aspect_ratio;

    vec2 half_extents = hole_size * aspect_ratio;
    float dist = sdf_box(uv - center, half_extents, corner_radius);

    float mask = smoothstep(0.0, feather, dist);
    COLOR = vec4(overlay_color.rgb, overlay_color.a * mask);
}