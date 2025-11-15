class_name Main
extends Node

var input_handler: InputHandler = InputHandler.new()

var player: Character = null
var rival: Character = null

func _ready():
	RenderingServer.set_default_clear_color(Color.from_hsv(0.5, 1, 0.8))

	var window = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	
	var camera = Camera3D.new()
	add_child(camera)
	camera.add_child(DirectionalLight3D.new())
	camera.position = Vector3(0, 0, 8)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 8
	
	var node = Node2D.new()
	add_child(node)
	node.position = window / 2

	var ground = ColorRect.new()
	ground.color = Color(0, 0.5, 0, 1)
	ground.size = window
	ground.position.x = - window.x / 2
	# ground.position.y = - window.y / 8
	node.add_child(ground)

	player = Character.new(0, Vector2(100, 150))
	player.position = Vector2(-200, -100)
	node.add_child(player)

	rival = Character.new(1, Vector2(100, 150))
	rival.position = Vector2(200, -100)
	node.add_child(rival)

	add_child(input_handler)

	input_handler.direction.connect(func(direction: Vector2) -> void:
		if direction.y != 0:
			return
		player.velocity += direction * 3
	)
	input_handler.pressed.connect(func() -> void:
		if player.position.y + player.size.y / 2 >= 0:
			player.velocity.y = -50
	)

func _process(delta: float) -> void:
	input_handler.process()
	player.process()
	rival.process()
