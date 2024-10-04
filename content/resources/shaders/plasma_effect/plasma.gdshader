shader_type canvas_item;

uniform float animation_speed_x = 0.2;
uniform float animation_speed_y = 0.1;
uniform vec4 plasma_color: hint_color = vec4(0.8, 0.8, 0.0, 1.0);
uniform sampler2D noise_texture: hint_black;
uniform float plasma_modifier: hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 uv = vec2(UV.x + TIME * animation_speed_x, UV.y + TIME * animation_speed_y);
	vec4 noise_color = texture(noise_texture, uv);
	
	vec4 noise_output = noise_color;

	vec4 unit_texture = texture(TEXTURE, UV);

	unit_texture.a = float(1.0) - unit_texture.a;

	float mask = float(1.0) - unit_texture.a;

	noise_output.a = noise_output.r * mask;

	vec4 final_shaded_texture = texture(TEXTURE,UV);

	noise_output.rgb = mix(noise_output.rgb, plasma_color.rgb, plasma_modifier);

	final_shaded_texture += noise_output;
	
	COLOR = final_shaded_texture;
//	COLOR = noise_color;
	
}