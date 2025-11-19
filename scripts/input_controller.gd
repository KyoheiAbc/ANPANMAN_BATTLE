class_name InputController
extends Node2D

var rect: Rect2 = Rect2(Vector2(-1000, -1000), Vector2(3000, 3000))
var pressed: Vector2 = Vector2.ZERO
var drag: Vector2 = Vector2.ZERO

func _input(input: InputEvent) -> void:
	if input is InputEventScreenTouch:
		if rect.has_point(input.position):
			if input.pressed:
				pressed = input.position
			drag = Vector2.ZERO

	elif input is InputEventScreenDrag:
		if rect.has_point(input.position):
			drag = input.position - pressed
