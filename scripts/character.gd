class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2 = Vector2.ZERO
var direction: int = 1

var attack_counts: Array[int] = []
var attack_area: AttackArea

var frame_count: int = -1

var rival: Character

var model: Model

var hp: int = 100
var walk_step: float = 8.0
var jump_power: float = 32.0
var velocity_x_decay: float = 0.8
var custom_gravity: float = 2.0
var one_attack_duration: int = 24
var special_duration: int = 60
var enable_physics: bool = true

var attack_damages: Array[Damage] = [
	Damage.new(10, Vector2(2, -16), 20),
	Damage.new(30, Vector2(16, -32), 20),
]

enum State {
	IDLE,
	ATTACKING,
	SPECIAL,
	FREEZE,
}
var state: State = State.IDLE

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
	if state != State.IDLE:
		return
	direction = walk_direction
	position.x += walk_direction * walk_step


func is_jumping() -> bool:
	return position.y + size.y / 2 < 0

func jump():
	if state != State.IDLE:
		return
	if is_jumping():
		return
	velocity.y = - jump_power

func attack():
	if state == State.ATTACKING:
		pass
	elif state != State.IDLE:
		return

	if attack_counts.size() >= 3:
		return
	if attack_counts.size() == 0:
		attack_counts.append(one_attack_duration)
		frame_count = 1000 * 1000
		state = State.ATTACKING
		enable_physics = false
		return
	if attack_counts[attack_counts.size() - 1] < one_attack_duration / 2:
		attack_counts.append(one_attack_duration)
		state = State.ATTACKING

func _attack_process():
	if attack_counts.size() == 0:
		return

	for i in range(attack_counts.size()):
		if attack_counts[i] >= 0:
			attack_process(float(one_attack_duration - attack_counts[i]) / one_attack_duration, i + 1)
		attack_counts[i] -= 1
		if attack_counts[i] >= 0:
			return
	
	frame_count = -1

func attack_process(progress: float, combo_count: int):
	if progress == 0:
		if attack_area:
			attack_area.queue_free()
		attack_area = AttackArea.new(self, size / 2, attack_damages[1] if combo_count == 3 else attack_damages[0])
		add_child(attack_area)
		attack_area.position.x = size.x * direction * 0.75
		model.punch(1 + (combo_count - 1) * 0.5)
	if progress > 0.5:
		if attack_area:
			attack_area.process()


func special():
	if state != State.IDLE:
		return
	state = State.SPECIAL
	frame_count = special_duration
	enable_physics = false

func special_process(progress: float) -> void:
	attack_process(progress, 3)
	position.x += direction * walk_step * 1.2

func damage(damage: Damage) -> void:
	if state == State.FREEZE:
		return
	idle()
	state = State.FREEZE
	hp -= damage.amount
	velocity = damage.vector
	frame_count = damage.duration

func process():
	if state == State.ATTACKING:
		_attack_process()
	elif state == State.SPECIAL:
		special_process(float(special_duration - frame_count) / special_duration)

	frame_count -= 1
	if frame_count < 0:
		idle()

	physics_process()

	clamp_position()

	model.process()

func idle() -> void:
	state = State.IDLE

	enable_physics = true

	attack_counts.clear()

	if attack_area:
		attack_area.queue_free()

func physics_process():
	if not enable_physics:
		return

	position += velocity

	velocity.x *= velocity_x_decay

	if is_jumping():
		velocity.y += custom_gravity
	else:
		velocity.y = 0
		position.y = - size.y / 2

func clamp_position():
	position.x = clamp(position.x, -800, 800)
	position.y = clamp(position.y, -400, -size.y / 2)

class Damage:
	var amount: int
	var vector: Vector2
	var duration: int

	var direction: int = 1

	func _init(amount: int, vector: Vector2, duration: int):
		self.amount = amount
		self.vector = vector
		self.duration = duration

class AttackArea extends Area2D:
	var character: Character
	var damage: Damage
	func _init(character: Character, size: Vector2, damage: Damage):
		self.character = character
		add_child(Main.CustomCollisionShape2D.new(size))

		self.damage = damage
		self.damage.direction = character.direction
		self.damage.vector.x = abs(self.damage.vector.x) * self.damage.direction

	func process() -> void:
		for area in get_overlapping_areas():
			if area == character.rival:
				character.rival.damage(damage)