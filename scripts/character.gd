class_name Character
extends Area2D

var size: Vector2
var model: Model

func _init(size: Vector2):
	self.size = size
	add_child(Main.CustomCollisionShape2D.new(size))
	position.y = - size.y / 2


func process():
	model.process()