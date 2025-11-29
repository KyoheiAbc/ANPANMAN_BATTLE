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
	if character.direction == 1:
		rotation_degrees.y = 0
	else:
		rotation_degrees.y = -90
		
	if character.state == Character.State.FREEZE:
		visible = false if Time.get_ticks_msec() % 160 < 80 else true
	else:
		visible = true

	if character.state == Character.State.ATTACKING or character.state == Character.State.SPECIAL:
		update_position()
		return
	
	if character.is_jumping():
		jump()
		update_position()
		return

	var diff_x = abs(character.position.x / 100 - position.x)
	if diff_x > 0.01:
		walk(Time.get_ticks_msec() / 1000.0 * diff_x * 16)
	else:
		idle()

	update_position()


func update_position():
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

func attack(finish: bool) -> void:
	punch(finish)

func punch(finish: bool) -> void:
	idle()
	if finish:
		all_rotation_x(90)
		arms[0].scale = Vector3.ONE * 2
	else:
		arms[0].rotation_degrees.x = -90
