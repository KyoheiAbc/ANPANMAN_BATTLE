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

var character: Character

func _init(character: Character) -> void:
	self.character = character

	var root = load(ASSETS[character.id]).instantiate()
	add_child(root)
	root.position.y = - character.size.y / 200
	root.rotation_degrees.y = -135
	
	right_arm = root.get_node("right_arm")
	left_arm = root.get_node("left_arm")
	right_leg = root.get_node("right_leg")
	left_leg = root.get_node("left_leg")

func process() -> void:
	if character.direction == 1:
		rotation_degrees.y = 0
	else:
		rotation_degrees.y = -90

	if character.attack == null:
		reset()

		var position_diff_x = abs(character.position.x / 100 - position.x)
		if position_diff_x > 0.01:
			var rotation = Time.get_ticks_msec() / 1000.0 * PI * 2 * (position_diff_x * 10)
			right_arm.rotation_degrees.x = sin(rotation) * 30
			left_arm.rotation_degrees.x = - sin(rotation) * 30
			right_leg.rotation_degrees.x = - sin(rotation) * 30
			left_leg.rotation_degrees.x = sin(rotation) * 30

		if not character.on_ground():
			right_arm.rotation_degrees.x = 30
			left_arm.rotation_degrees.x = -30
			right_leg.rotation_degrees.x = -30
			left_leg.rotation_degrees.x = 30
	

	position = Vector3(character.position.x / 100, -character.position.y / 100, 0)

func reset() -> void:
	right_arm.rotation_degrees = Vector3.ZERO
	right_arm.scale = Vector3.ONE
	left_arm.rotation_degrees = Vector3.ZERO
	right_leg.rotation_degrees = Vector3.ZERO
	left_leg.rotation_degrees = Vector3.ZERO

func set_attack_pose(active: bool) -> void:
	if active:
		right_arm.rotation_degrees.x = 90
		right_arm.scale = 2 * Vector3.ONE
		left_arm.rotation_degrees.x = -45
		right_leg.rotation_degrees.x = -90
		left_leg.rotation_degrees.x = 90
	else:
		right_arm.rotation_degrees.x = -90
		right_arm.scale = Vector3.ONE
		left_arm.rotation_degrees.x = 45
		right_leg.rotation_degrees.x = 90
		left_leg.rotation_degrees.x = -90