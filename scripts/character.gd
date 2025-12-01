class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2 = Vector2.ZERO
var direction: int = 1

var attack_counts: Array[int] = []
var attack_areas: Array[AttackArea] = []

var frame_count: int = -1

var characters: Array[Character] = []

var model: Model

var hp: int = 100
var jump_power: float = 32.0
var custom_gravity: float = 2.0
var walk_acceleration: float = 2.0
var max_x_velocity: float = 16.0
var velocity_x_decay: float = 0.8
var one_attack_duration: int = 24
var special_duration: int = 60

var attack_damages: Array[Damage] = [
	Damage.new(self, 10, Vector2(2, -8), 20, 3),
	Damage.new(self, 10, Vector2(4, -16), 20, 6),
	Damage.new(self, 30, Vector2(8, -32), 20, 9),
	Damage.new(self, 30, Vector2(16, -64), 20, 12),
]

enum State {
	IDLE,
	ATTACKING,
	SPECIAL,
	FREEZE,
}
var state: State = State.IDLE

func _init(characters: Array[Character], size: Vector2):
	self.characters = characters

	self.size = size
	add_child(Main.CustomCollisionShape2D.new(size))

	position.y = - size.y / 2

	match self.get_script():
		Anpan:
			model = Anpan.AnpanModel.new(self)
		Baikin:
			model = Baikin.BaikinModel.new(self)

	add_child(model)


func walk(walk_direction: int) -> void:
	if state != State.IDLE:
		return
	direction = walk_direction
	add_x_velocity(direction * walk_acceleration)

func add_x_velocity(x_velocity: float) -> void:
	velocity.x += x_velocity
	velocity.x = clamp(velocity.x, -max_x_velocity, max_x_velocity)

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
		return
	if attack_counts[attack_counts.size() - 1] < one_attack_duration / 2:
		attack_counts.append(one_attack_duration)
		state = State.ATTACKING
		
func attack_process(progress: float, combo_count: int) -> void:
	if progress == 0:
		model.attack(false)
		attack_areas.append(AttackArea.new(self, size / 2, attack_damages[combo_count - 1].duplicate()))
		add_child(attack_areas[-1])
		attack_areas[-1].position.x = size.x * 0.75 * direction
	elif 0.333 < progress and progress < 0.666:
		attack_areas[-1].process()
	elif progress >= 0.666 and progress < 1.0:
		pass
	elif progress == 1.0:
		var attack_area = attack_areas.pop_back()
		attack_area.queue_free()
	
	if progress_equal(progress, 0.333):
		model.attack(true)

func special():
	if state != State.IDLE:
		return
	state = State.SPECIAL
	frame_count = special_duration

func special_process(progress: float) -> void:
	pass

func progress_equal(progress: float, target: float) -> bool:
	return int(one_attack_duration * target) / float(one_attack_duration) == progress

func damage(damage: Damage) -> void:
	if state == State.FREEZE:
		return
	if damage.character == characters[0]:
		if Main.FREEZE_COUNT < 0:
			Main.FREEZE_COUNT = damage.hit_stop
	idle()
	state = State.FREEZE
	hp -= damage.amount
	velocity = damage.vector
	frame_count = damage.duration

func process():
	if state == State.ATTACKING:
		for i in range(attack_counts.size()):
			if attack_counts[i] >= 0:
				attack_process(float(one_attack_duration - attack_counts[i]) / one_attack_duration, i + 1)
			attack_counts[i] -= 1
			if attack_counts[i] >= 0:
				return
		frame_count = -1
	elif state == State.SPECIAL:
		special_process(float(special_duration - frame_count) / special_duration)

	frame_count -= 1
	if frame_count < 0:
		if state != State.IDLE:
			idle()

	physics_process()

	clamp_position()

	model.process()

func idle() -> void:
	state = State.IDLE

	velocity = Vector2.ZERO

	attack_counts.clear()

	for attack_area in attack_areas:
		attack_area.queue_free()
	attack_areas.clear()

	model.idle()

func physics_process():
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
	var character: Character

	var amount: int
	var vector: Vector2
	var duration: int

	var hit_stop: int

	func _init(character: Character, amount: int, vector: Vector2, duration: int, hit_stop: int):
		self.character = character
		self.amount = amount
		self.vector = vector
		self.duration = duration
		self.vector.x *= self.character.direction
		self.hit_stop = hit_stop

	func duplicate() -> Damage:
			return Damage.new(character, amount, vector, duration, hit_stop)

class AttackArea extends Area2D:
	var character: Character
	var damage: Damage
	func _init(character: Character, size: Vector2, damage: Damage):
		self.character = character
		add_child(Main.CustomCollisionShape2D.new(size))

		self.damage = damage

	func process() -> void:
		for area in get_overlapping_areas():
			for other_character in character.characters:
				if other_character == character:
					continue
				if area == other_character:
					other_character.damage(damage)
