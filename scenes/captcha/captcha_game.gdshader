shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
	// Animating the blur is maybe a bit too ugly even for this project lmao
	COLOR = texture(TEXTURE, UV) * textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	//COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
}
