extends Node2D

class_name Cursor

@onready var audio = $AudioStreamPlayer2D
@onready var hitTimer = $HitTimer
@onready var healthLabel = $HealthLabel
@onready var collision = $Area2D/CollisionShape2D

signal dead

var health : int = 100
var isDead : bool = false

func _process(_delta):
	healthLabel.text = str(health)
	
	if not isDead:
		check_if_dead()

func handle_hit(dmg: int) -> void:
	health -= dmg

func restore_health(hp: int) -> void:
	health += hp

func check_if_dead() -> void:
	if health <= 0:
		collision.disabled = true
		dead.emit()
