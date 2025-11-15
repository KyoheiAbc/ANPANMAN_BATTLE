class_name Character
extends Area2D

class CustomCollisionShape2D extends CollisionShape2D:
	func _init(size: Vector2):
		self.shape = RectangleShape2D.new()
		self.shape.size = size

		var color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.color = Color.from_hsv(randf(), 1, 1, 0)
		color_rect.size = size
		color_rect.position = - size / 2

var velocity: Vector2 = Vector2.ZERO
var size: Vector2 = Vector2.ZERO
var model: Model
var id: int = 0

func _init(id: int, size: Vector2):
	self.id = id
	self.size = size
	add_child(CustomCollisionShape2D.new(size))
	model = Model.new(self)
	add_child(model)

func process():
	position += velocity


	for area in get_overlapping_areas():
		if area is Character:
			area.velocity.x += 15 if area.position.x > position.x else -15
			area.velocity.y = -15
			

	velocity.y += 5
	velocity.x = clamp(velocity.x * 0.7, -10, 10)

	if position.y + size.y / 2 > 0:
		position.y = - size.y / 2
		velocity.y = 0
	position.x = clamp(position.x, -800 + size.x / 2, 800 - size.x / 2)


	model.process()

func walk(x: int) -> void:
	velocity.x += x * 3
	if x > 0:
		model.rotation_degrees.y = 0
	elif x < 0:
		model.rotation_degrees.y = -90

func jump() -> void:
	if position.y + size.y / 2 >= 0:
		velocity.y = -50