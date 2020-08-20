extends TileMap

#scenes
onready var slime = load("res://Slime.tscn")
onready var eagle = load("res://Eagle.tscn")
onready var cherry = load("res://Cherry.tscn")

onready var enemies = [slime,eagle,cherry]

func _ready():
	randomize()
	add_objects()

func add_objects():
	var used_cells = get_used_cells()
	for i in used_cells.size():
		var cell = get_cellv(used_cells[i])
		create(enemies[cell],used_cells[i],cell,i)
	clear()

func create(type, used_cell, id, index):
	var instance = type.instance()
	if type == cherry:
		if Master.picked_cherries.has(index):
			return
		else:
			instance.id = index
	elif type == slime:
		if randi()%2 == 1:
			instance.get_node("Sprite").scale.x *= -1
	var rect = get_tileset().tile_get_region(id)
	instance.position = map_to_world(used_cell) + rect.size/2.0
	add_child(instance)
