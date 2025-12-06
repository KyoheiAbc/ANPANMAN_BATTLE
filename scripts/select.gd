class_name Select extends Node

const CELL_SIZE := 160

var sprites: Array[Sprite2D] = []
var cursor: ColorRect
var map := Array2D.new_array_2d(Vector2(4, 2), -1)
var model: Node3D
var old_index := -1
var relative_position := Vector2.ZERO

func _ready() -> void:
	Main.PLAYER_INDEX = 0
	Array2D.set_value(map, Array2D.value_to_vector2(map, Main.PLAYER_INDEX), 0)
	_setup_sprites()
	_setup_cursor()
	_setup_start_button()
	_setup_camera()

func _setup_sprites() -> void:
	var offset := Main.WINDOW / 2 - Vector2(1.5, 0.5) * CELL_SIZE
	for i in Main.SPRITES.size():
		var sprite := Sprite2D.new()
		sprite.texture = Main.SPRITES[i]
		sprite.position = Vector2(i % 4, i / 4) * CELL_SIZE + offset
		sprites.append(sprite)
		add_child(sprite)

func _setup_cursor() -> void:
	cursor = ColorRect.new()
	cursor.color = Color.RED
	cursor.size = Vector2(150, 150)
	cursor.z_index = -1
	add_child(cursor)

func _setup_start_button() -> void:
	var button := Button.new()
	button.size = Vector2(360, 100)
	button.add_theme_font_size_override("font_size", 48)
	button.text = "START"
	button.position = Main.WINDOW / 2 - button.size / 2 + Vector2(0, 300)
	button.pressed.connect(_on_start_pressed)
	add_child(button)

func _on_start_pressed() -> void:
	Main.PLAYER_INDEX = Array2D.get_position_value(map, 0)
	Main.RIVAL_INDEXES.clear()
	for i in Main.SPRITES.size():
		if i != Main.PLAYER_INDEX:
			Main.RIVAL_INDEXES.append(i)
	Main.RIVAL_INDEXES.shuffle()

	queue_free()
	Main.NODE.add_child(Arcade.new())

func _setup_camera() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 0, 8)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.5
	add_child(camera)
	
	var light := DirectionalLight3D.new()
	camera.add_child(light)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		relative_position = Vector2.ZERO
	elif event is InputEventScreenDrag:
		relative_position += event.relative
		for axis in [Vector2.AXIS_X, Vector2.AXIS_Y]:
			var dir := Vector2.RIGHT if axis == Vector2.AXIS_X else Vector2.DOWN
			if relative_position[axis] > CELL_SIZE:
				relative_position[axis] -= CELL_SIZE
				Array2D.move_value(map, Main.PLAYER_INDEX, dir)
			elif relative_position[axis] < -CELL_SIZE:
				relative_position[axis] += CELL_SIZE
				Array2D.move_value(map, Main.PLAYER_INDEX, -dir)

func _process(_delta: float) -> void:
	_update_cursor()
	_update_model()

func _update_cursor() -> void:
	cursor.position = sprites[Array2D.get_position_value(map, Main.PLAYER_INDEX)].position - cursor.size / 2

func _update_model() -> void:
	var idx := Array2D.get_position_value(map, 0)
	if old_index == idx:
		return
	old_index = idx
	if model:
		model.queue_free()
	model = Main.MODELS[0 if idx == 0 else 1].instantiate()
	model.position = Vector3(-1.75, -0.75, 0)
	model.rotation_degrees.y = -150
	add_child(model)