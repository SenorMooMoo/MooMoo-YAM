shader_type canvas_item;

uniform vec4 plasma_color: hint_color = vec4(0.8, 0.8, 0.0, 1.0);
uniform float plasma_modifier: hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, plasma_color.rgb, plasma_modifier);
	COLOR = color;
}