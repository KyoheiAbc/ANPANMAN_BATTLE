class_name Model
extends Node3D

const ROOT_Y_DIVISOR := 200
const ROOT_ROT_Y := -135
const ROT_Y_RIGHT := 0
const ROT_Y_LEFT := -90
const FREEZE_BLINK_PERIOD := 160
const FREEZE_BLINK_HALF := 80
const POS_DIVISOR := 100
const WALK_DIFF_THRESHOLD := 0.01
const WALK_PERIOD := 800.0
const WALK_ROT_X := 30
const JUMP_ROT_X := 30
const ATTACK_PREPARE_SCALE := 1.0
const ATTACK_ROT_X := 90
const ATTACK_ARM1_ROT_X := -45

var root: Node3D

var arms: Array[Node3D] = []
var legs: Array[Node3D] = []

var character: Character


func _init(character: Character, model_scene: PackedScene = null) -> void:
	self.character = character
	
	root = model_scene.instantiate()
	
	add_child(root)
	root.position.y = - character.size.y / ROOT_Y_DIVISOR
	root.rotation_degrees.y = ROOT_ROT_Y

	arms = [root.get_node("right_arm"), root.get_node("left_arm")]
	legs = [root.get_node("right_leg"), root.get_node("left_leg")]

func process():
	if character.direction == 1:
		rotation_degrees.y = ROT_Y_RIGHT
	else:
		rotation_degrees.y = ROT_Y_LEFT
		
	if character.state == Character.State.FREEZE:
		visible = false if Time.get_ticks_msec() % FREEZE_BLINK_PERIOD < FREEZE_BLINK_HALF else true
	else:
		visible = true

	if character.state == Character.State.ATTACKING or character.state == Character.State.SPECIAL:
		update_position()
		return

	if character.state == Character.State.IDLE:
		if character.is_jumping():
			jump()
		else:
			var diff_x = abs(character.position.x / POS_DIVISOR - position.x)
			if diff_x > WALK_DIFF_THRESHOLD:
				walk(Time.get_ticks_msec() / WALK_PERIOD)
			else:
				idle()

	update_position()

func update_position():
	position = Vector3(character.position.x / POS_DIVISOR, -character.position.y / POS_DIVISOR, 0)

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
	all_rotation_x(WALK_ROT_X * sin(PI * 2 * progress))

func jump() -> void:
	all_rotation_x(JUMP_ROT_X)

func attack_prepare() -> void:
	attack(ATTACK_PREPARE_SCALE)
	for arm in arms:
		arm.rotation_degrees.x *= -1
	for leg in legs:
		leg.rotation_degrees.x *= -1
	
func attack(scale: float) -> void:
	idle()
	all_rotation_x(ATTACK_ROT_X)
	arms[0].scale = Vector3.ONE * scale
	arms[1].rotation_degrees.x = ATTACK_ARM1_ROT_X
	arms[1].scale = Vector3.ONE
