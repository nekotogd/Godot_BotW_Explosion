shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 fire_color : hint_color = vec4(0.99, 0.31, 0.01, 1.0);
uniform float fire_strength = 4.3;
uniform float warble_strength = 0.2;
uniform float time_scale = 1.0;
uniform float alpha_scissor = 0.23;
uniform sampler2D red_texture : hint_albedo;
uniform sampler2D green_texture : hint_albedo;
uniform sampler2D blue_texture : hint_albedo;
uniform sampler2D noise_texture : hint_albedo;

vec3 lerp(vec3 a, vec3 b, float t){
	return a * (1.0 - t) + b * t;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}


void vertex() {
	mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
	mat_world = mat_world * mat4( vec4(cos(INSTANCE_CUSTOM.x),-sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat_world;
}




void fragment() {
	vec2 base_uv = UV;
	vec3 r = texture(red_texture, base_uv).rgb;
	vec3 g = texture(green_texture, base_uv).rgb;
	vec3 b = texture(blue_texture, base_uv).rgb;
	ALPHA = clamp(b.b * COLOR.a, 0.0, 1.0) + texture(noise_texture, UV + TIME * time_scale).r * warble_strength;
	ALPHA_SCISSOR = alpha_scissor;
	vec3 fragment_world_pos = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
	ALBEDO = lerp(g * fire_color.rgb * fire_strength, r, COLOR.r);
}
