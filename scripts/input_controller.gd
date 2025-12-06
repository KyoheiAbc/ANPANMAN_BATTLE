class_name InputController
extends Node

const RECT_POSITION := Vector2(-1000, -1000)
const RECT_SIZE := Vector2(3000, 3000)

var rect: Rect2 = Rect2(RECT_POSITION, RECT_SIZE)
var pressed: Vector2 = Vector2.ZERO
var drag: Vector2 = Vector2.ZERO

signal signal_pressed(position: Vector2)

func _input(input: InputEvent) -> void:
	if input is InputEventScreenTouch:
		if rect.has_point(input.position):
			if input.pressed:
				pressed = input.position
				emit_signal("signal_pressed", pressed)
			drag = Vector2.ZERO

	elif input is InputEventScreenDrag:
		if rect.has_point(input.position):
			drag = input.position - pressed