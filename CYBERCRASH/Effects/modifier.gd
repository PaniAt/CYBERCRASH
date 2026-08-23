class_name Modifier
extends Object

## Fade types
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

# Modifier instance values
var value := 0.0 ## Intensity 
var duration := 0.0 ## How long it lasts
var initial_duration := 0.0 ## How long it started with
var fade := Fade.NONE ## Fade mode
var inverse_fade := false ## Does it fade inversely
var custom_exp := 1.0 ## For custom exponential fade mode

## Constructs a new modifier
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

## Gets the intensity of the modifier
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
