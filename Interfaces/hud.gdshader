shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.rgb == vec3(1.0)) {
		COLOR.rgb = 1.0 - textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	}
	COLOR.a = texture(TEXTURE, UV).a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
