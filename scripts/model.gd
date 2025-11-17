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

func walk() -> void:
	var phase = Time.get_ticks_msec() / 100.0
	right_arm.scale = Vector3(1, 1, 1)
	left_arm.scale = Vector3(1, 1, 1)
	right_arm.rotation_degrees.x = sin(phase) * 45
	left_arm.rotation_degrees.x = - sin(phase) * 45
	right_leg.rotation_degrees.x = - sin(phase) * 45
	left_leg.rotation_degrees.x = sin(phase) * 45

func jump() -> void:
	right_arm.rotation_degrees.x = 45
	left_arm.rotation_degrees.x = -45
	right_leg.rotation_degrees.x = -45
	left_leg.rotation_degrees.x = 45
	
func idle() -> void:
	right_arm.rotation_degrees.x = 0
	right_arm.scale = Vector3(1, 1, 1)
	left_arm.rotation_degrees.x = 0
	right_leg.rotation_degrees.x = 0
	left_leg.rotation_degrees.x = 0

func attack() -> void:
	var attack_instance = character.attack.attack_instance
	if attack_instance == null:
		return
	if attack_instance.frame_counter < 10:
		right_arm.rotation_degrees.x = -90
		right_arm.scale = Vector3(1, 1, 1)
		left_arm.rotation_degrees.x = 45
		right_leg.rotation_degrees.x = 45
		left_leg.rotation_degrees.x = -45
	elif attack_instance.frame_counter < 20:
		right_arm.rotation_degrees.x = 90
		right_arm.scale = Vector3(2, 2, 2)
		left_arm.rotation_degrees.x = -45
		right_leg.rotation_degrees.x = -45
		left_leg.rotation_degrees.x = 45
