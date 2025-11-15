class_name InputHandler
extends Node

signal pressed(position: Vector2)
signal released()
signal direction(direction: Vector2)

var threshold: int = 16
var drag_area_end_x: float = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.8

var base_position = null
var delta: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.pressed:
			return
		if event.keycode == KEY_W or event.keycode == KEY_UP:
			emit_signal("direction", Vector2(0, -1))
		if event.keycode == KEY_S or event.keycode == KEY_DOWN:
			emit_signal("direction", Vector2(0, 1))
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			emit_signal("direction", Vector2(-1, 0))
		if event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			emit_signal("direction", Vector2(1, 0))
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			emit_signal("pressed", Vector2(0, 0))


	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > drag_area_end_x:
				emit_signal("pressed", event.position)
			else:
				base_position = event.position
		if not event.pressed:
			emit_signal("released")
			if event.position.x < drag_area_end_x:
				base_position = null
				delta = Vector2.ZERO


	if event is InputEventScreenDrag:
		if base_position == null:
			return
		if event.position.x > drag_area_end_x:
			return
		delta = event.position - base_position

func _process(_delta: float) -> void:
	if delta.x > threshold:
		emit_signal("direction", Vector2(1, 0))
	elif delta.x < -threshold:
		emit_signal("direction", Vector2(-1, 0))
	elif delta.y > threshold:
		emit_signal("direction", Vector2(0, 1))
	elif delta.y < -threshold:
		emit_signal("direction", Vector2(0, -1))
