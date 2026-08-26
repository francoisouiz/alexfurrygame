shader_type canvas_item;

uniform sampler2D front_tex;
uniform sampler2D back_tex;
uniform float progress: hint_range(0.0, 1.0) = 0.0;
uniform float direction = 1.0;

void fragment() {
	float angle = progress * PI;
	float x_scale = cos(angle);
	
	float hinge = 0.5;
	float extent = 0.5 * x_scale * direction;
	
	float outer_edge = hinge + extent;

    float lo = min(hinge, outer_edge);
    float hi = max(hinge, outer_edge);
    if (UV.x < lo || UV.x > hi) {
        discard;
    }

    float t = (UV.x - hinge) / extent;
	
	if (direction < 0.0) {
		t = 1.0 - t;
	}

    float spine_side = (direction > 0.0) ? 0.0 : 1.0;
    float fuv_x = spine_side + t * (1.0 - 2.0 * spine_side);

    vec4 col;
    if (x_scale * direction >= 0.0) {
        col = texture(front_tex, vec2(fuv_x, UV.y));
    } else {
        col = texture(back_tex, vec2(1.0 - fuv_x, UV.y));
    }

    float shade = mix(1.0, 0.35, sin(angle));
    col.rgb *= shade;

    COLOR = col;
}
