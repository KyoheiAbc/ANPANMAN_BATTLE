class_name InputController
extends Node2D

var buttons: Array[Rect2] = []
var drag_area: Rect2
var drag_relative: Vector2 = Vector2.ZERO

signal button(id: int)
signal drag(direction: Vector2)

func _init():
	var window = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

	position = - window / 2

	drag_area = Rect2(Vector2.ZERO, window)
	drag_area.size.x = window.x * 0.7

	for i in range(4):
		buttons.append(Rect2(Vector2.ZERO, Vector2(150, 150)))
		var color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.size = buttons[i].size
		if i == 0:
			buttons[0].position = Vector2(window.x - 150, window.y - 300) - buttons[0].size
			color_rect.color = Color.from_hsv(3 / 5.0, 1, 1, 0.5)
		elif i == 1:
			buttons[1].position = Vector2(window.x - 300, window.y - 150) - buttons[1].size
			color_rect.color = Color.from_hsv(2 / 5.0, 1, 1, 0.5)
		elif i == 2:
			buttons[2].position = Vector2(window.x, window.y - 150) - buttons[2].size
			color_rect.color = Color.from_hsv(0, 1, 1, 0.5)
		elif i == 3:
			buttons[3].position = Vector2(window.x - 150, window.y) - buttons[3].size
			color_rect.color = Color.from_hsv(1 / 5.0, 1, 1, 0.5)
		color_rect.position = buttons[i].position

func _input(input_event: InputEvent) -> void:
	if input_event is InputEventScreenTouch:
		if input_event.pressed:
			for i in range(buttons.size()):
				if buttons[i].has_point(input_event.position):
					emit_signal("button", i)
					return

		if drag_area.has_point(input_event.position):
			drag_relative = Vector2.ZERO

	elif input_event is InputEventScreenDrag:
		if drag_area.has_point(input_event.position):
			drag_relative += input_event.relative

func process():
	if abs(drag_relative.x) > 10:
		emit_signal("drag", Vector2(sign(drag_relative.x), 0))