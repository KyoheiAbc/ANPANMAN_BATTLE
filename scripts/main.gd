class_name Main
extends Node

static var NODE: Node = null
static var WINDOW: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

static var PLAYER_INDEX: int = 0
static var RIVAL_INDEXES: Array[int] = [1, 2, 3, 4, 5, 6, 7]
static var HIT_STOP_COUNT: int = 0

const MODELS: Array[PackedScene] = [
	preload("res://assets/a.gltf"),
	preload("res://assets/b.gltf"),
	preload("res://assets/a.gltf"),
	preload("res://assets/a.gltf"),
	preload("res://assets/a.gltf"),
	preload("res://assets/a.gltf"),
	preload("res://assets/a.gltf"),
	preload("res://assets/a.gltf"),
]

const SPRITES: Array[Texture2D] = [
	preload("res://assets/a_edited.png"),
	preload("res://assets/b_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
]

func _init() -> void:
	NODE = self
	NODE.add_child(Initial.new())
	camera()

class Initial extends Node:
	func _init() -> void:
		var label = Main.label_new()
		add_child(label)
		label.text = "ANPANMAN BATTLE"

	func _input(event: InputEvent) -> void:
		if event is InputEventScreenTouch and event.pressed:
			self.queue_free()
			Main.NODE.add_child(Select.new())

func camera() -> void:
	RenderingServer.set_default_clear_color(Color(0, 0.5, 1))

	var camera_3d = Camera3D.new()
	add_child(camera_3d)
	camera_3d.position = Vector3(0, 0, 8)
	camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera_3d.size = 8
	var light = DirectionalLight3D.new()
	camera_3d.add_child(light)
	light.shadow_enabled = false

	var camera_2d = Camera2D.new()
	add_child(camera_2d)

static func label_new() -> Label:
	var label = Label.new()
	label.position = - Main.WINDOW / 2
	label.size = Main.WINDOW
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 128)
	label.add_theme_color_override("font_color", Color(1, 1, 0))
	return label
