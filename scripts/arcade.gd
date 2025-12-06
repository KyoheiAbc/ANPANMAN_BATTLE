class_name Arcade
extends Node

const CELL_SIZE := 160
var sprites: Array[Sprite2D] = []
var cursors: Array[ColorRect] = []

func _ready() -> void:
	_setup_sprites()
	_setup_cursor()

	cursors[0].position = sprites[Main.PLAYER_INDEX].position - cursors[0].size / 2
	cursors[1].position = sprites[Main.RIVAL_INDEXES[0]].position - cursors[1].size / 2

	var model: Node3D = null
	model = Main.MODELS[Main.PLAYER_INDEX].instantiate()
	model.position = Vector3(-1.75, -0.75, 0)
	model.rotation_degrees.y = -150
	add_child(model)

	model = Main.MODELS[Main.RIVAL_INDEXES[0]].instantiate()
	model.position = Vector3(1.75, -0.75, 0)
	model.rotation_degrees.y = 150
	add_child(model)

	sprites[Main.PLAYER_INDEX].modulate = Color(1, 1, 1, 1)
	for i in Main.RIVAL_INDEXES:
		sprites[i].modulate = Color(1, 1, 1, 1)
	
	_setup_camera()

	await get_tree().create_timer(1.5).timeout
	Main.NODE.add_child(Game.new())
	self.queue_free()


func _setup_camera() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 0, 8)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.5
	add_child(camera)
	
	var light := DirectionalLight3D.new()
	camera.add_child(light)

func _setup_sprites() -> void:
	var offset := Main.WINDOW / 2 - Vector2(1.5, 0.5) * CELL_SIZE
	for i in Main.SPRITES.size():
		var sprite := Sprite2D.new()
		sprite.texture = Main.SPRITES[i]
		sprite.position = Vector2(i % 4, i / 4) * CELL_SIZE + offset
		sprites.append(sprite)
		add_child(sprite)
		sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)


func _setup_cursor() -> void:
	for i in 2:
		var cursor := ColorRect.new()
		cursor.color = Color.RED if i == 0 else Color.BLUE
		cursor.size = Vector2(150, 150)
		cursor.z_index = -1
		cursors.append(cursor)
		add_child(cursor)