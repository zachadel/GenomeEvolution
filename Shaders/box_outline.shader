shader_type canvas_item;
render_mode blend_premul_alpha;

// This shader only works properly with premultiplied alpha blend mode.
uniform float top_percent = .1;
uniform float left_percent = .1;
uniform float right_percent = .1;
uniform float bottom_percent = .1;

uniform vec4 outline_color: hint_color;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	
	if(UV.x < right_percent || UV.x > 1.0 - left_percent || UV.y < top_percent || UV.y > 1.0 - bottom_percent)
	{
		COLOR = outline_color
	}
	else
	{
		COLOR = col
	}
}
