class_name Model
extends Node3D

var root: Node3D

var arms: Array[Node3D] = []
var legs: Array[Node3D] = []

var character: Character

func _init(character: Character) -> void:
	self.character = character
	
	match self.get_script():
		Anpan.AnpanModel:
			root = load("res://assets/a.gltf").instantiate()
		Baikin.BaikinModel:
			root = load("res://assets/b.gltf").instantiate()
	
	add_child(root)
	root.position.y = - character.size.y / 200
	root.rotation_degrees.y = -135

	arms = [root.get_node("right_arm"), root.get_node("left_arm")]
	legs = [root.get_node("right_leg"), root.get_node("left_leg")]

func process():
	# visible = false if Time.get_ticks_msec() % 100 < 50 else true
	if character.direction() == 1:
		rotation_degrees.y = 0
	else:
		rotation_degrees.y = -90

	if character.is_on_floor() == false:
		jump()
	elif abs(character.position.x / 100 - position.x) > 0.01:
		walk(Time.get_ticks_msec() / 500.0)
	else:
		idle()
	position = Vector3(character.position.x / 100, -character.position.y / 100, 0)

func idle() -> void:
	all_rotation_x(0)
	for arm in arms:
		arm.scale = Vector3.ONE
	for leg in legs:
		leg.scale = Vector3.ONE

func all_rotation_x(x_degrees: float) -> void:
	arms[0].rotation_degrees.x = x_degrees
	arms[1].rotation_degrees.x = - x_degrees
	legs[0].rotation_degrees.x = - x_degrees
	legs[1].rotation_degrees.x = x_degrees

func walk(progress: float) -> void:
	all_rotation_x(30 * sin(PI * 2 * progress))

func jump() -> void:
	all_rotation_x(30)
