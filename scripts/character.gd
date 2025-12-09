class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2 = Vector2.ZERO
var direction: int = 1

var hp: int

var rival: Character

var frame_count: int = -1

var model: Model

var attacks: Array[Attack] = []
var attack_cool_time: int = 0
var attack_cool_time_max: int = 16
var special_cool_time: int = 0
var special_cool_time_max: int = 160
var hp_max: int = 256
var walk_acceleration: float = 1.0
var jump_velocity: float = -16.0
var friction: float = 0.92
var character_gravity: float = 0.8
var attack_move: float = 2.0
var dash_velocity: float = 24.0

var audio_player = AudioStreamPlayer.new()


const EFFECT_SOUND: AudioStream = preload("res://assets/effect.mp3")


enum State {
	IDLE,
	ATTACKING,
	SPECIAL,
	FREEZE,
	LOSE,
}
var state: State = State.IDLE

var attack_infos: Array[Attack.Info] = [
	Attack.Info.new([8, 2, 8], Vector2(50, 0), Vector2(100, 100), 8, Vector2(0, -8), 8, 32),
	Attack.Info.new([8, 2, 8], Vector2(50, 0), Vector2(100, 100), 8, Vector2(0, -8), 8, 32),
	Attack.Info.new([8, 2, 16], Vector2(50, 0), Vector2(100, 100), 8, Vector2(64, -8), 8, 32),
	Attack.Info.new([16, 48, 16], Vector2(50, 0), Vector2(100, 100), 32, Vector2(64, -32), 64, 32),
]

static func character_new(index: int) -> Character:
	var character: Character
	var model_scene: PackedScene = Main.MODELS[index]
	match index:
		0:
			character = Anpan.new()
			character.model = Anpan.AnpanModel.new(character, model_scene)
		1:
			character = Baikin.new()
			character.model = Baikin.BaikinModel.new(character, model_scene)
		_:
			character = Anpan.new()
			character.model = Anpan.AnpanModel.new(character, model_scene)

	character.add_child(character.model)
	return character

func _init(size: Vector2):
	self.size = size
	add_child(Game.CustomCollisionShape2D.new(size))

	position.y = - size.y / 2

	hp = hp_max
	attack_cool_time = attack_cool_time_max

	add_child(audio_player)
	audio_player.stream = EFFECT_SOUND

func walk(walk_direction: int) -> void:
	if state != State.IDLE:
		return
	velocity.x += walk_acceleration * walk_direction

func is_jumping() -> bool:
	return position.y + size.y / 2 < 0

func jump():
	if state != State.IDLE:
		return
	if is_jumping():
		return
	velocity.y = jump_velocity

func dash():
	velocity.x += dash_velocity * direction

func attack():
	if state == State.ATTACKING:
		pass
	elif state != State.IDLE:
		return
	if attack_cool_time < attack_cool_time_max:
		return

	if attacks.size() == 0:
		attacks.append(Attack.new(self, attack_infos[0], 1))
		add_child(attacks[-1])
		state = State.ATTACKING
		frame_count = 1000000

	elif attacks.size() >= 3:
		return

	var last_attack = attacks[-1]
	if last_attack.frame_count < attack_infos[attacks.size()].counts[1] + attack_infos[attacks.size()].counts[2]:
		attacks.append(Attack.new(self, attack_infos[attacks.size()], attacks.size() + 1))
		add_child(attacks[-1])
		state = State.ATTACKING
		frame_count = 1000000
	
func damage(attack: Attack) -> void:
	if state == State.FREEZE:
		return
	idle()
	state = State.FREEZE
	hp -= attack.info.damage
	
	audio_player.play()

	frame_count = attack.info.freeze_count
	velocity = attack.info.knockback
	velocity.x *= attack.direction
	Main.HIT_STOP_COUNT = attack.info.hit_stop

	if hp <= 0:
		state = State.LOSE
		frame_count = 1000000


func special():
	if state != State.IDLE:
		return
	if special_cool_time < special_cool_time_max:
		return
	state = State.SPECIAL
	attacks.append(Attack.new(self, attack_infos[3], 1000))
	add_child(attacks[-1])
	frame_count = 1000000

func unique_process(attack: Attack) -> void:
	if state == State.SPECIAL:
		if attack.is_active_frame():
			position.x += 16 * direction
		velocity = Vector2.ZERO
	
func process():
	if state == State.ATTACKING:
		var attack_finished = true
		for attack in attacks:
			if attack.process():
				attack_finished = false
				break
		if attack_finished:
			frame_count = 0
			attack_cool_time = 0
	elif state == State.SPECIAL:
		var attack = attacks[0]
		if not attack.process():
			frame_count = 0
			special_cool_time = 0

	attack_cool_time += 1
	special_cool_time += 1

	frame_count -= 1
	if frame_count < 0:
		if state != State.IDLE:
			idle()

	if state == State.IDLE:
		look_at_rival()
	
	physics_process()

	clamp_position()

	model.process()

func idle() -> void:
	if state == State.LOSE:
		return
	state = State.IDLE

	# velocity = Vector2.ZERO

	for attack in attacks:
		attack.queue_free()
	attacks.clear()

	model.idle()

func look_at_rival() -> void:
	direction = 1 if position.x < rival.position.x else -1

func physics_process():
	position += velocity

	velocity.x *= friction

	if is_jumping():
		velocity.y += character_gravity
	else:
		velocity.y = 0
		position.y = - size.y / 2

func clamp_position():
	if state == State.LOSE:
		return
	if position.x < -600:
		velocity.x += 6.4
	elif position.x > 600:
		velocity.x -= 6.4
	position.x = clamp(position.x, -640, 640)
	position.y = clamp(position.y, -320, -size.y / 2)


class Attack extends Area2D:
	var character: Character
	var frame_count: int = 0
	var info: Info
	var direction: int = 1
	var collision_shape: Game.CustomCollisionShape2D
	var current_combo: int = 0
	class Info:
		var counts: Array[int]
		var position: Vector2
		var size: Vector2
		var damage: int
		var knockback: Vector2
		var freeze_count: int
		var hit_stop: int
		func _init(counts: Array[int], position: Vector2, size: Vector2, damage: int, knockback: Vector2, freeze_count: int, hit_stop: int) -> void:
			self.counts = counts
			self.position = position
			self.size = size
			self.damage = damage
			self.knockback = knockback
			self.freeze_count = freeze_count
			self.hit_stop = hit_stop
	func total_frame_count() -> int:
		return info.counts[0] + info.counts[1] + info.counts[2]
	func is_prepare_frame() -> bool:
		return info.counts[1] + info.counts[2] <= frame_count
	func is_active_frame() -> bool:
		return info.counts[2] < frame_count and frame_count < info.counts[1] + info.counts[2]
	func is_recover_frame() -> bool:
		return frame_count <= info.counts[2]

	func _init(character: Character, info: Info, current_combo: int) -> void:
		self.character = character
		self.info = info
		direction = character.direction
		frame_count = info.counts[0] + info.counts[1] + info.counts[2]
		position = info.position * Vector2(direction, 1)
		collision_shape = Game.CustomCollisionShape2D.new(info.size)
		self.current_combo = current_combo
		add_child(collision_shape)

	func process() -> bool:
		if frame_count < 0:
			return false
		if frame_count == total_frame_count():
			character.model.action()
			character.velocity.x += character.attack_move * direction
		elif frame_count == info.counts[2]:
			character.model.idle()
		character.unique_process(self)
		frame_count -= 1
		if info.counts[2] < frame_count and frame_count < info.counts[1] + info.counts[2]:
			for area in get_overlapping_areas():
				if area == character.rival:
					area.damage(self)

		return frame_count >= 0