class_name InputController
extends Node

var rect: Rect2 = Rect2(Vector2(-1000, -1000), Vector2(3000, 3000))
var i: int = -1
signal sig(i: int)

func _input(input: InputEvent) -> void:
	if input is InputEventScreenTouch:
		if rect.has_point(input.position):
			if input.pressed:
				i = 0
			else:
				sig.emit(i)
				i = -1
func process() -> void:
	if i != -1:
		i += 1