class_name Model
extends Node3D

const ASSETS: Array[String] = [
	"res://assets/a.gltf",
	"res://assets/b.gltf",
]

var right_arm: Node3D
var left_arm: Node3D
var right_leg: Node3D
var left_leg: Node3D

func _init(character: Character) -> void:
	var packed_scene = PackedScene.new()

	var gltf = load(ASSETS[character.id]).instantiate()
	packed_scene.pack(gltf)
	gltf.queue_free()

	var scene = packed_scene.instantiate()
	add_child(scene)
	scene.position.y = - character.size.y / 200
	scene.rotation_degrees.y = -135
	
	right_arm = scene.get_node("right_arm")
	left_arm = scene.get_node("left_arm")
	right_leg = scene.get_node("right_leg")
	left_leg = scene.get_node("left_leg")