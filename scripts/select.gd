class_name Select extends Node


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

var sprites: Array[Sprite2D]
var cursor: ColorRect
var map: Array

func _ready() -> void:
	map = Array2D.new_array_2d(Vector2(4, 2), -1)
	Array2D.set_value(map, Array2D.value_to_vector2(map, Main.PLAYER_INDEX), 0)

	var center: Vector2 = Vector2.ZERO
	for i in range(SPRITES.size()):
		sprites.append(Sprite2D.new())
		add_child(sprites.back())
		sprites.back().scale = Vector2(1, 1)
		sprites.back().texture = SPRITES[i]
		sprites.back().position = Vector2(i % 4 * 160, 160 * int(i / 4))
		center += sprites.back().position / SPRITES.size()
	for sprite in sprites:
		sprite.position += Main.WINDOW / 2 - center

	cursor = ColorRect.new()
	add_child(cursor)
	cursor.color = Color.from_hsv(0, 1, 1)
	cursor.size = Vector2(150, 150)
	cursor.z_index = -1

	var button = Button.new()
	add_child(button)
	button.size = Vector2(300, 120)
	button.add_theme_font_size_override("font_size", 64)
	button.text = "START"
	button.position = Main.WINDOW / 2 - button.size / 2
	button.position.y += 300
	button.pressed.connect(func() -> void:
		if frame_count < 60:
			return
		Main.PLAYER_INDEX = Array2D.get_position_value(map, 0)
		self.queue_free()
		Main.NODE.add_child(Arcade.new())
	)


	var camera_3d = Camera3D.new()
	add_child(camera_3d)
	var light = DirectionalLight3D.new()
	camera_3d.add_child(light)
	light.shadow_enabled = false
	camera_3d.position = Vector3(0, 0, 8)
	camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera_3d.size = 2.5


var selected: bool = false
var relative_position: Vector2
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		selected = true
		relative_position = Vector2.ZERO
	if event is InputEventScreenDrag:
		if selected:
			relative_position += event.relative
			if relative_position.x > 160:
				relative_position.x -= 160
				Array2D.move_value(map, Main.PLAYER_INDEX, Vector2(1, 0))
			elif relative_position.x < -160:
				relative_position.x += 160
				Array2D.move_value(map, Main.PLAYER_INDEX, Vector2(-1, 0))
			if relative_position.y > 160:
				relative_position.y -= 160
				Array2D.move_value(map, Main.PLAYER_INDEX, Vector2(0, 1))
			elif relative_position.y < -160:
				relative_position.y += 160
				Array2D.move_value(map, Main.PLAYER_INDEX, Vector2(0, -1))
var old_index: int = -1
var model: Node3D
var frame_count: int = 0
func _process(delta: float) -> void:
	frame_count += 1
	var position: Vector2 = Array2D.get_position(map, Main.PLAYER_INDEX)
	cursor.position = sprites[Array2D.vector2_to_value(map, position)].position - cursor.size / 2

	var map_index = Array2D.get_position_value(map, 0)
	if old_index != map_index:
		old_index = map_index
		if model != null:
			model.queue_free()
			model = null
		if map_index == 0:
			model = Model.MODELS[0].instantiate()
		else:
			model = Model.MODELS[1].instantiate()
		add_child(model)
		model.position = Vector3(-1.75, -0.75, 0)
		model.rotation_degrees.y = -150
