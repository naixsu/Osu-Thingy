extends Node

@onready var queueFreeTimer : Timer = $Timers/QueueFreeTimer
@onready var approachCircleTimer : Timer = $Timers/ApproachCircleTimer
@onready var approachCircle : Sprite2D = $ApproachCircle

var clickable : bool = true
var approachRate : float = 0.0

func _physics_process(_delta):
	#var timer_progress = 1.0 - (approachCircleTimer.time_left / approachCircleTimer.wait_time)
	#var scaled_progress = timer_progress * approachRate
	#var new_scale = lerp(0.5, 0.1, scaled_progress)
	#approachCircle.scale = Vector2(new_scale, new_scale)
	
	pass
	
	
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("Cursor") and clickable:
		queue_free()

func _on_queue_free_timer_timeout():
	queue_free() 
