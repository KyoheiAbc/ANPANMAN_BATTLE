class_name Main
extends Node

static var NODE: Node = null
static var WINDOW: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

func _init() -> void:
	NODE = self
	NODE.add_child(Game.new())

class Initial extends Node:
	func _init() -> void:
		RenderingServer.set_default_clear_color(Color.from_hsv(0.15, 0.5, 1))
		var label = Main.label_new()
		add_child(label)
		label.text = "ANPANMAN BATTLE"

	func _input(event: InputEvent) -> void:
		if event is InputEventScreenTouch and event.pressed:
			self.queue_free()
			Main.NODE.add_child(Game.new())


static func label_new() -> Label:
	var label = Label.new()
	label.size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 128)
	label.add_theme_color_override("font_color", Color.from_hsv(0, 0.75, 1))
	return label
