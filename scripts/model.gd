class_name Model
extends Node3D

var root: Node3D

var arms: Array[Node3D] = []
var legs: Array[Node3D] = []

var character: Character

func _init(character: Character) -> void:
	self.character = character
	add_child(root)
	root.position.y = - character.size.y / 200
	root.rotation_degrees.y = -135

func process():
	position = Vector3(character.position.x / 100, -character.position.y / 100, 0)
