class_name Array2D

static func new_array_2d(size: Vector2, default_value) -> Array:
	var array_2d: Array = []
	for y in range(size.y):
		var row: Array = []
		for x in range(size.x):
			row.append(default_value)
		array_2d.append(row)
	return array_2d

static func out_of_bounds(pos: Vector2, array_2d: Array) -> bool:
	if pos.x < 0 or pos.y < 0:
		return true
	if pos.x >= array_2d[0].size() or pos.y >= array_2d.size():
		return true
	return false

static func get_size(array_2d: Array) -> Vector2:
	return Vector2(array_2d[0].size(), array_2d.size())

static func get_position_value(array_2d: Array, value: int) -> int:
	var position = get_position(array_2d, value)
	return vector2_to_value(array_2d, position)

static func get_value(array_2d: Array, position: Vector2):
	return array_2d[position.y][position.x]
static func set_value(array_2d: Array, position: Vector2, value) -> void:
	array_2d[position.y][position.x] = value

static func get_position(array_2d: Array, value) -> Vector2:
	for y in range(array_2d.size()):
		for x in range(array_2d[0].size()):
			if array_2d[y][x] == value:
				return Vector2(x, y)
	return Vector2(-1, -1)

static func warp_position(array_2d: Array, position: Vector2) -> Vector2:
	var size = get_size(array_2d)
	if position.x < 0:
		position.x = size.x - 1
	if position.x >= size.x:
		position.x = 0
	if position.y < 0:
		position.y = size.y - 1
	if position.y >= size.y:
		position.y = 0
	return position

static func move_value(array_2d: Array, value, delta: Vector2) -> bool:
	var initial_position = get_position(array_2d, value)
	var old_position = initial_position
	var new_position: Vector2
	for i in range(max(array_2d.size(), array_2d[0].size())):
		new_position = warp_position(array_2d, old_position + delta)
		if get_value(array_2d, new_position) == -1:
			set_value(array_2d, initial_position, -1)
			set_value(array_2d, new_position, value)
			return true
		old_position = new_position

	return false
	
static func vector2_to_value(array_2d: Array, vector2: Vector2) -> int:
	var size = get_size(array_2d)
	return int(vector2.y) * int(size.x) + int(vector2.x)
static func value_to_vector2(array_2d: Array, value: int) -> Vector2:
	var size = get_size(array_2d)
	var y = int(value / size.x)
	var x = value % int(size.x)
	return Vector2(x, y)
