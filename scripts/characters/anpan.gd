class_name Anpan
extends Character

func _init(characters: Array[Character]) -> void:
	# attack_damages = [
	# 	Damage.new(10, Vector2(2, -8), 20),
	# 	Damage.new(10, Vector2(4, -16), 20),
	# 	Damage.new(20, Vector2(8, -32), 20),
	# 	Damage.new(30, Vector2(16, -64), 30),
	# ]
	# special_duration *= 1.5
	# one_attack_duration *= 1.5
	super._init(characters, Vector2(100, 150))
	
func special_process(progress: float) -> void:
	if progress == 0:
		model.attack(false)
		enable_physics = false
		attack_areas.append(AttackArea.new(self, size / 2, attack_damages[3].duplicate()))
		add_child(attack_areas[-1])
		attack_areas[-1].position.x = size.x * 0.75 * direction
	elif 0.333 < progress and progress < 1.0:
		model.attack(true)
		attack_areas[-1].process()
	elif progress == 1.0:
		var attack_area = attack_areas.pop_back()
		attack_area.queue_free()
	
	enable_physics = false
	position.x += direction * walk_step * 1.5

class AnpanModel extends Model:
	pass
