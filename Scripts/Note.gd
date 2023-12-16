extends Node

@onready var queueFreeTimer : Timer = $Timers/QueueFreeTimer
@onready var approachCircleTimer : Timer = $Timers/ApproachCircleTimer
@onready var approachCircle : Sprite2D = $ApproachCircle
@onready var hitCircle : Sprite2D = $HitCircle
@onready var combo = $Combo

var clickable : bool = false
var approachRate : float = 0.0
var mouseInArea : bool = false
var cursor : Node2D

func _process(_delta):
	if mouseInArea and clickable:
		hit_note()

func _physics_process(_delta):
	var timerProgress = 1.0 - (approachCircleTimer.time_left / approachCircleTimer.wait_time)
	var newScale = lerp(0.5, 0.1, timerProgress)
	approachCircle.scale = Vector2(newScale, newScale)
	# set the modulate from 0 to 1 depending on the timerProgress
	#var hitCircleModulate = timerProgress 
	var mappedValue = approachCircleTimer.time_left / approachCircleTimer.wait_time
	var hitCircleModulate = lerp(0, 1, 1.0 - mappedValue)
	hitCircle.set_self_modulate(Color(1, 1, 1, hitCircleModulate))
	
	
func _on_area_2d_area_entered(area):
	#if area.get_parent().is_in_group("Cursor") and clickable:
		#queue_free()
	if area.get_parent().is_in_group("Cursor"):
		mouseInArea = true
		cursor = area.get_parent()

func _on_queue_free_timer_timeout():
	SoundManager.comboBreak.play()
	BulletManager.spawn_bullets(self.position)
	queue_free() 

func _on_approach_circle_timer_timeout():
	clickable = true
	queueFreeTimer.start()
	#play_hitsound()


func _on_area_2d_area_exited(area):
	if area.get_parent().is_in_group("Cursor"):
		mouseInArea = false
		area = null

func hit_note():
	if cursor.hitTimer.is_stopped():
		cursor.hitTimer.start()
		cursor.restore_health(5)
		SoundManager.hitSound.play()
		queue_free()
