extends Node

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_timer_timeout():
	queue_free()

func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("Cursor"):
		queue_free()
