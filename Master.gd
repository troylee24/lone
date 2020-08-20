extends Node

var lives = 3
var checkpoint = "Spawn"

var picked_cherries = []
var total_cherries = 0

func lose_heart():
	lives -= 1
	if lives <= 0:
		lives = 3
		picked_cherries.resize(0)
		checkpoint = "Spawn"
	var err = get_tree().reload_current_scene()
	return err == OK

func add_cherry(id):
	picked_cherries.append(id)
	var HUD = get_tree().get_root().get_node("World/CanvasLayer/HUD")
	HUD.add_cherry(picked_cherries.size())
