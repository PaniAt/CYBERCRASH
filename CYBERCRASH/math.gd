extends Node

## Three-dimensional arctangent.
func atan3(diff: Vector3) -> Vector2:
	var out: Vector2
	out.x = atan2(diff.x, diff.z)
	var dist = sqrt(diff.z * diff.z + diff.x * diff.x)
	out.y = atan2(-diff.y, dist)
	return out

## Arctangent with a diff of two Vector2s
func atan2v(diff: Vector2) -> float:
	return atan2(diff.y, diff.x)

## Arctangent with horizontal of two Vector3s.
func atan2d(v1: Vector3, v2: Vector3) -> float:
	return atan2v(Vector2(v1.z, v1.x) - Vector2(v2.z, v2.x))

## Horizontal length of a Vector3 (x and z).
func hlen(vec: Vector3) -> float:
	return Vector2(vec.x, vec.z).length()

## Squared horizontal length of a Vector3 (x and z).
func hlen_sqr(vec: Vector3) -> float:
	return Vector2(vec.x, vec.z).length_squared()

## Returns whether vec1 is within horizontal range of vec2
func within(vec1: Vector3, vec2: Vector3, dist: float) -> bool:
	return (vec1 - vec2).length_squared() <= dist * dist
