class_name InputController
extends Node

var rect: Rect2 = Rect2(Vector2(-1000, -1000), Vector2(3000, 3000))
var pressed: Vector2 = Vector2.ZERO
var drag: Vector2 = Vector2.ZERO

var pressed_time: float = 8.0

signal signal_pressed(position: Vector2, double_tap: bool)

func _input(input: InputEvent) -> void:
	if input is InputEventScreenTouch:
		if rect.has_point(input.position):
			if input.pressed:
				pressed = input.position
				if pressed_time < 0.25:
					emit_signal("signal_pressed", pressed, true)
				else:
					emit_signal("signal_pressed", pressed, false)
				pressed_time = 0.0
			drag = Vector2.ZERO

	elif input is InputEventScreenDrag:
		if rect.has_point(input.position):
			drag = input.position - pressed

func _process(delta: float) -> void:
	pressed_time += delta