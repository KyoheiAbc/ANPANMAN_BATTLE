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
	root.remove_child(right_arm)
	right_arm.owner = null
	var right_arm_root = Node3D.new()
	root.add_child(right_arm_root)
	right_arm_root.position = right_arm.position
	right_arm_root.add_child(right_arm)
	right_arm.position = Vector3.ZERO

	
	left_arm = root.get_node("left_arm")
	right_leg = root.get_node("right_leg")
	left_leg = root.get_node("left_leg")

func _process(_delta: float) -> void:
	var new_position = Vector3(character.position.x / 100, -character.position.y / 100, 0)
	if (new_position - self.position).length_squared() > 0.001 and character.stun_count == 0:
		var phase = walk_count / 5.0
		right_arm.rotation_degrees.x = sin(phase) * 45
		left_arm.rotation_degrees.x = - sin(phase) * 45
		right_leg.rotation_degrees.x = - sin(phase) * 45
		left_leg.rotation_degrees.x = sin(phase) * 45
		# var phase = 45 if (walk_count % 30) < 15 else -45
		# right_arm.rotation_degrees.x = phase
		# left_arm.rotation_degrees.x = - phase
		# right_leg.rotation_degrees.x = - phase
		# left_leg.rotation_degrees.x = phase
		walk_count += 1
	elif character.attack == null:
		walk_count = 0
		reset()

	if character.stun_count > 0:
		root.visible = Time.get_ticks_msec() % 100 < 50
		# rotation_degrees.x = -45
		right_arm.rotation_degrees.z = 135
		left_arm.rotation_degrees.z = -135
		right_leg.rotation_degrees.z = 90
		left_leg.rotation_degrees.z = -90
	else:
		root.visible = true

	if character.direction > 0:
		rotation_degrees.y = 0
	elif character.direction < 0:
		rotation_degrees.y = -90

	
	self.position = new_position

	if character.is_jumping() and character.stun_count == 0:
		right_arm.rotation_degrees.x = 90
		left_arm.rotation_degrees.x = -90
		right_leg.rotation_degrees.x = -90
		left_leg.rotation_degrees.x = 90

func reset() -> void:
	rotation_degrees.x = 0
	right_arm.rotation_degrees = Vector3.ZERO
	left_arm.rotation_degrees = Vector3.ZERO
	right_leg.rotation_degrees = Vector3.ZERO
	left_leg.rotation_degrees = Vector3.ZERO
