class_name Character
extends Area2D

var id: int
var model: Model
var size: Vector2

func _init(id: int, size: Vector2):
	self.id = id
	self.size = size
	add_child(Main.CustomCollisionShape2D.new(size))
	model = Model.new(self)
	add_child(model)

func process():
	model.position = Vector3(position.x / 100, -position.y / 100, 0)