shader_type spatial;
instance uniform float progress: hint_range(0.0, 1.0, 0.1) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.5, 0.0, 0.0);
	ALPHA = progress;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
