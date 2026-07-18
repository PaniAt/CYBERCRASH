class_name Modifier
extends Object

enum Fade
{
	NONE,
	LINEAR,
	QUADRATIC,
	QUINTIC,
	SQUARE_ROOT,
	CUSTOM_EXP,
	SMOOTHSTEP,
	SINE,
}
var value := 0.0
var duration := 0.0
var initial_duration := 0.0
var fade := Fade.NONE
var inverse_fade := false
var custom_exp := 1.0

static func of(
	val: float, time: float, 
	fades := Fade.NONE, expo := 1.0,
	inverse := false) -> Modifier:
	var modifier = Modifier.new()
	modifier.value = val
	modifier.duration = time
	modifier.initial_duration = time
	modifier.fade = fades
	modifier.custom_exp = expo
	modifier.inverse_fade = inverse
	return modifier


func get_strength() -> float:
	var ratio = duration / initial_duration
	ratio = clampf(ratio, 0.0, 1.0)
	if inverse_fade:
		ratio = 1.0 - ratio
	match (fade):
		Fade.NONE:
			return value
		Fade.LINEAR:
			return value * ratio
		Fade.QUADRATIC:
			return value * (ratio ** 2)
		Fade.QUINTIC:
			return value * (ratio ** 3)
		Fade.SQUARE_ROOT:
			return value * sqrt(ratio)
		Fade.CUSTOM_EXP:
			return value * (ratio ** custom_exp)
		Fade.SMOOTHSTEP:
			return smoothstep(value, 0.0, ratio)
		Fade.SINE:
			return value * sin(PI * ratio)
	return value
