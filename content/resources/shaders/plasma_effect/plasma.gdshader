shader_type canvas_item;

uniform float animation_speed_x = 0.2;
uniform float animation_speed_y = 0.1;
uniform vec4 plasma_color: hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D noise_texture: hint_black;
uniform float plasma_modifier: hint_range(0.0, 1.0) = 0.17;

void fragment() {
	vec2 uv = vec2(UV.x + TIME * animation_speed_x, UV.y + TIME * animation_speed_y);
	vec4 noise_output = texture(noise_texture, uv);

	vec4 final_shaded_texture = texture(TEXTURE,UV);

	noise_output.rgb = mix(noise_output.rgb, plasma_color.rgb, plasma_modifier);

	float mask = step(-final_shaded_texture.w, -0.9);
	float mask2 = step(final_shaded_texture.y, 0.6);
	float mask3 = step(-final_shaded_texture.z, -0.3);
	
	final_shaded_texture.rgb += noise_output.rgb * vec3(mask) * vec3(mask2) * vec3(mask3);
	
	COLOR = final_shaded_texture;
}