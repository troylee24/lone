extends TileMap

onready var used_cells = get_used_cells()

var folder_path = "res://Objects/Scenes/"

func _ready():
	total_cherries()
	add_objects()

func total_cherries():
	var cherries = get_used_cells_by_id(2).size()
	if cherries != Master.total_cherries:
		Master.total_cherries = cherries

func add_objects():
	for i in used_cells.size():
		var idx = get_cellv(used_cells[i])
		var id = tile_set.tile_get_name(idx)
		var path = folder_path + id + ".tscn"
		create(load(path),id, used_cells[i],idx,i)
	clear()

func create(object, id, tile_pos, idx, i):
	var instance = object.instance()
	if id == "Cherry":
		#respawn
		if Master.picked_cherries.has(i):
			return #don't instance
		else:
			instance.id = i
	var rect = get_tileset().tile_get_region(idx)
	instance.position = map_to_world(tile_pos) + rect.size/2.0
	add_child(instance)
