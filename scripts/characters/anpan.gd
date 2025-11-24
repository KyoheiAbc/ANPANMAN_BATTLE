class_name Anpan
extends Character

var attack_counts: Array[int]
var one_attack_duration: int = 24
var attack_area: Area2D = Area2D.new()

func _init():
	super._init(Vector2(100, 150))
	add_child(attack_area)
	attack_area.add_child(Main.CustomCollisionShape2D.new(Vector2(100, 100)))
	attack_area.area_entered.connect(func(area: Area2D) -> void:
		if area == rival:
			rival.velocity.x = 2 * direction
			rival.velocity.y = -16
			attack_area.set_deferred("monitoring", false)
	)
	attack_area.monitoring = false
	
func attack():
	if attack_counts.size() >= 3:
		return
	if attack_counts.size() == 0:
		attack_area.position.x = 100 * direction
		
	attack_counts.append(one_attack_duration)
	attack_count = 1000

func attack_process():
	for i in range(attack_counts.size()):
		attack_counts[i] -= 1
		var combo_count = i + 1
		model.punch(false if combo_count == 2 else true, 1 + 0.5 * (combo_count - 1))

		if attack_counts[i] == one_attack_duration / 2:
			attack_area.monitoring = true

		if attack_counts[i] >= 0:
			return

	attack_counts.clear()
	attack_count = -1
	attack_area.monitoring = false

class AnpanModel extends Model:
	pass
