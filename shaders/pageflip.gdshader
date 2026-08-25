shader_type canvas_item;

uniform sampler2D front_tex;
uniform sampler2D back_tex;
uniform float progress: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float angle = progress * PI;
	float x_scale = cos(angle);
	vec2 uv = UV;
	
	uv.x = (uv.x - 0.5) / max(abs(x_scale), 0.001) + 0.5;
	
	if (uv.x < 0.0 || uv.x > 1.0) {
		discard;
	}
	
	vec4 col;
	if (x_scale >= 0.0) {
		col = texture(front_tex, uv);
	} else {
		uv.x = 1.0 - uv.x;
		col = texture(back_tex, uv);
	}
	
	float shade = mix(1.0, 0.35, sin(angle));
	col.rgb *= shade;
	
	COLOR = col;
}
