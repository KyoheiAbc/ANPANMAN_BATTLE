class_name Character
extends Area2D

var speed: float = 1.0

var size: Vector2
var velocity: Vector2

var attacks: Array[One]

var rival: Character

var control_enabled: bool = true
var physics_enabled: bool = true

var model: Model

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

func attack():
	if attacks.size() >= 3:
		return
	attacks.append(One.new(16 / speed))

func attack_count() -> int:
	for i in range(attacks.size()):
		if attacks[i].frame_count > 0:
			return i + 1
	return 0

func is_on_floor() -> bool:
	return position.y + size.y / 2 >= 0

func direction() -> int:
	return 1 if rival.position.x > position.x else -1

func physics_process():
	if not physics_enabled:
		return
	position += velocity

	velocity.x *= 0.8
	if is_on_floor():
		velocity.y = 0
		position.y = - size.y / 2
	else:
		velocity.y += 1

func clamp_position():
	position.x = clamp(position.x, -800, 800)
	position.y = clamp(position.y, -400, -size.y / 2)

func process():
	physics_process()

	clamp_position()

	attack_process()

	model.process()


func attack_process():
	if attacks.size() == 0:
		return

	for atk in attacks:
		if atk.process():
			return

	attacks.clear()


class One:
	var frame_count: int = 0
	func _init(frame_count: int):
		self.frame_count = frame_count
	func process() -> bool:
		frame_count -= 1
		return frame_count > 0
