class_name Model
extends Node3D

var root: Node3D

var arms: Array[Node3D] = []
var legs: Array[Node3D] = []

var character: Character
var walk_count: int = 0

func _init(character: Character, model_scene: PackedScene = null) -> void:
	self.character = character
	
	root = model_scene.instantiate()
	
	add_child(root)
	root.position.y = - character.size.y / 200
	root.rotation_degrees.y = -135

	arms = [root.get_node("RightArm"), root.get_node("LeftArm")]
	legs = [root.get_node("RightLeg"), root.get_node("LeftLeg")]

func process():
	if character.direction == 1:
		rotation_degrees.y = 0
	else:
		rotation_degrees.y = -90
		
	if character.state == Character.State.FREEZE or character.state == Character.State.LOSE:
		visible = false if Time.get_ticks_msec() % 160 < 80 else true
	else:
		visible = true


	if character.state == Character.State.IDLE:
		if character.is_jumping():
			jump()
		else:
			var diff_x = abs(character.position.x / 100 - position.x)
			if diff_x > 0.01:
				walk()
			else:
				walk_count = 0
				idle()

	update_position()


func update_position():
	position = Vector3(character.position.x / 100, -character.position.y / 100, 0)

func idle() -> void:
	all_rotation_x(0)

func all_rotation_x(x_degrees: float) -> void:
	arms[0].rotation_degrees.x = x_degrees
	arms[1].rotation_degrees.x = - x_degrees
	legs[0].rotation_degrees.x = - x_degrees
	legs[1].rotation_degrees.x = x_degrees

func walk() -> void:
	var progress = sin(2.0 * PI * walk_count / 30.0)
	all_rotation_x(45 * progress)
	walk_count += 1

func jump() -> void:
	all_rotation_x(45)

func action() -> void:
	all_rotation_x(90)
