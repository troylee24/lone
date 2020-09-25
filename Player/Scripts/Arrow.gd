extends RigidBody2D

onready var despawnTimer = $DespawnTimer

func _ready():
	despawnTimer.start(5)

func _on_DespawnTimer_timeout():
	queue_free()
