class_name Model
extends Node3D

const PACKED_SCENES: Array[PackedScene] = [
	preload("res://assets/a.gltf"),
	preload("res://assets/b.gltf"),
]


var root: Node3D = null
var right_arm: Node3D
var left_arm: Node3D
var right_leg: Node3D
var left_leg: Node3D

func _init(id: int):
	var scene = PackedScene.new()
	var gltf = PACKED_SCENES[id].instantiate()
	scene.pack(gltf)
	root = scene.instantiate()
	add_child(root)
	gltf.queue_free()

	root.rotation_degrees = Vector3(0, -135, 0)

	right_arm = root.get_node("right_arm")
	left_arm = root.get_node("left_arm")
	right_leg = root.get_node("right_leg")
	left_leg = root.get_node("left_leg")
