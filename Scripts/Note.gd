extends Node

@onready var queueFreeTimer : Timer = $Timers/QueueFreeTimer
@onready var approachCircleTimer : Timer = $Timers/ApproachCircleTimer
@onready var approachCircle : Sprite2D = $ApproachCircle

var clickable : bool = false
var approachRate : float = 0.0
var mouseInArea : bool = false
var cursor : Node2D

func _process(_delta):
	if mouseInArea and clickable:
		hit_note()

func _physics_process(_delta):
	var timer_progress = 1.0 - (approachCircleTimer.time_left / approachCircleTimer.wait_time)
	#var scaled_progress = timer_progress * approachRate
	var new_scale = lerp(0.5, 0.1, timer_progress)
	approachCircle.scale = Vector2(new_scale, new_scale)
	
	
func _on_area_2d_area_entered(area):
	#if area.get_parent().is_in_group("Cursor") and clickable:
		#queue_free()
	if area.get_parent().is_in_group("Cursor"):
		mouseInArea = true
		cursor = area.get_parent()

func _on_queue_free_timer_timeout():
	queue_free() 

func _on_approach_circle_timer_timeout():
	clickable = true
	#play_hitsound()


func _on_area_2d_area_exited(area):
	if area.get_parent().is_in_group("Cursor"):
		mouseInArea = false
		area = null

func hit_note():
	if cursor.hitTimer.is_stopped():
		cursor.hitTimer.start()
		SoundManager.hitSound.play()
		queue_free()
