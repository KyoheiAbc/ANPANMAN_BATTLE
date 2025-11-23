class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2

var rival: Character

var control_enabled: bool = true
var physics_enabled: bool = true

var model: Model

var walk_step: float = 8.0
var jump_power: float = 32.0
var velocity_x_decay: float = 0.8
var custom_gravity: float = 2.0

var attack_count: int = 0
var special_attack_count: int = 0

func _init(size: Vector2):
	self.size = size
	add_child(Main.CustomCollisionShape2D.new(size))

	position.y = - size.y / 2

	match self.get_script():
		Anpan:
			model = Anpan.AnpanModel.new(self)
		Baikin:
			model = Baikin.BaikinModel.new(self)

	add_child(model)

func walk(walk_direction: int):
	if control_enabled == false:
		return
	position.x += walk_direction * walk_step

func is_on_floor() -> bool:
	return position.y + size.y / 2 >= 0
	
func jump():
	if control_enabled == false:
		return
	if not is_on_floor():
		return
	velocity.y = - jump_power


func attack():
	pass

func attack_process():
	attack_count = -1

func special_attack():
	pass

func special_attack_process():
	special_attack_count = -1


func direction() -> int:
	return 1 if rival.position.x > position.x else -1

func physics_process():
	if not physics_enabled:
		return
	position += velocity

	velocity.x *= velocity_x_decay
	if is_on_floor():
		velocity.y = 0
		position.y = - size.y / 2
	else:
		velocity.y += custom_gravity

func clamp_position():
	position.x = clamp(position.x, -800, 800)
	position.y = clamp(position.y, -400, -size.y / 2)

func process():
	if special_attack_count > 0:
		special_attack_process()
	
	if attack_count > 0:
		attack_process()

	physics_process()

	clamp_position()

	model.process()
