extends Node

signal slime_squash
signal update_health
signal add_cherry

var lives = 3
var checkpoint = "Spawn"

var picked_cherries = []
var total_cherries = 0

func lose_heart():
	lives -= 1
	if lives <= 0:
		reset()
	get_tree().reload_current_scene()

func reset():
	lives = 3
	picked_cherries.resize(0)
	checkpoint = "Spawn"

func add_cherry(id):
	if !picked_cherries.has(id):
		picked_cherries.append(id)
	emit_signal("add_cherry")
