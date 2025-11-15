class_name Model
extends Node3D

const PACKED_SCENES: Array[PackedScene] = [
	preload("res://assets/a.gltf"),
	preload("res://assets/b.gltf"),
]

var character: Character

var root: Node3D = null
var right_arm: Node3D
var left_arm: Node3D
var right_leg: Node3D
var left_leg: Node3D

var walk_count: int = 0

func _init(character: Character):
	self.character = character

	var scene = PackedScene.new()
	var gltf = PACKED_SCENES[self.character.id].instantiate()
	scene.pack(gltf)
	root = scene.instantiate()
	root.position.y = - character.size.y / 200

	add_child(root)
	gltf.queue_free()

	root.rotation_degrees = Vector3(0, -135, 0)

	right_arm = root.get_node("right_arm")
	left_arm = root.get_node("left_arm")
	right_leg = root.get_node("right_leg")
	left_leg = root.get_node("left_leg")

func process():
	var new_position = Vector3(character.position.x / 100, -character.position.y / 100, 0)
	if (new_position - self.position).length_squared() > 0.001:
		# var phase = walk_count / 5.0
		# right_arm.rotation_degrees.x = sin(phase) * 45
		# left_arm.rotation_degrees.x = - sin(phase) * 45
		# right_leg.rotation_degrees.x = - sin(phase) * 45
		# left_leg.rotation_degrees.x = sin(phase) * 45
		var phase = 45 if (walk_count % 30) < 15 else -45
		right_arm.rotation_degrees.x = phase
		left_arm.rotation_degrees.x = - phase
		right_leg.rotation_degrees.x = - phase
		left_leg.rotation_degrees.x = phase
		walk_count += 1
	else:
		walk_count = 0
		right_arm.rotation_degrees.x = 0
		left_arm.rotation_degrees.x = 0
		right_leg.rotation_degrees.x = 0
		left_leg.rotation_degrees.x = 0

	
	self.position = new_position

	if character.position.y + character.size.y / 2 < 0:
		right_arm.rotation_degrees.x = 90
		left_arm.rotation_degrees.x = -90
		right_leg.rotation_degrees.x = -90
		left_leg.rotation_degrees.x = 90
