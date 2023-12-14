extends CharacterBody2D

@export var speed = 1000
@export var damage = 20

@onready var lifespan = $Lifespan

var gravity = 0
var direction : Vector2

func _ready():
	direction = Vector2(1, 0).rotated(rotation)

func _physics_process(delta):
	velocity = speed * direction
	
	move_and_slide()

func _on_area_2d_area_entered(area):
	if area.get_parent() is Cursor:
		area.get_parent().handle_hit(damage)
		queue_free()

func _on_lifespan_timeout():
	queue_free()
