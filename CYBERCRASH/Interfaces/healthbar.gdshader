shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float ratio: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec3 flash: source_color = vec3(1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (UV.x < ratio)
	{
		COLOR.rgb = mix(
			texture(TEXTURE, UV).rgb, flash, progress
		);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
