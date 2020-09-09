extends Node
class_name DungeonGeneration

var room = preload("res://src/map/Square.tscn")

var max_x = 6
var max_y = 4

func generate(room_seed: int, room_range: Array):
	seed(room_seed)
	var dungeon = {}
	var size = floor(rand_range(room_range[0], room_range[1]))
	
	dungeon[Vector2(0,0)] = room.instance()
	size -= 1
	
	while(size > 0):
		for i in dungeon.keys():
			if dungeon[i].connections > 1:
				if randf() < .3 * dungeon[i].connections:
					pass
			var roll = randi() % 4
			var direction = Vector2.ZERO
			var ok = false
			while !ok:
				roll = randi() % 4
				if roll == 0:
					direction = Vector2.UP
				if roll == 1:
					direction = Vector2.RIGHT
				if roll == 2:
					direction = Vector2.LEFT
				if roll == 3:
					direction = Vector2.DOWN
				var pos = i + direction
				if pos.x < max_x and pos.x > -1 \
					and pos.y < max_y and pos.y > -1:
						ok = true
			var pos = i + direction
			if !dungeon.has(pos):
				dungeon[pos] = room.instance()
				size -= 1
			if dungeon.get(i).connected_squares.get(direction) == null:
				if dungeon.get(pos).connections > 1:
					continue
				connect_rooms(dungeon.get(i), dungeon.get(pos), direction)
	return dungeon

func connect_rooms(room1, room2, direction):
	room1.connected_squares[direction] = room2
	room2.connected_squares[-direction] = room1
	room1.connections += 1
	room2.connections += 1

func is_interesting(dungeon):
	var room_with_three = 0
	for i in dungeon.keys():
		if(dungeon.get(i).connections >= 3):
			room_with_three += 1
	return room_with_three >= 2
