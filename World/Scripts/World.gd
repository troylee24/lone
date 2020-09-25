extends Node2D

onready var bounds = $Bounds
onready var checkpoints = $Checkpoints
onready var player = $Player

func _ready():
	randomize()
	player.position = checkpoints.get_node(Master.checkpoint).position

func _process(_delta):
	if player.position.y > bounds.position.y:
		Master.lose_heart()
