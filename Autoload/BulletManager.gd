extends Node2D

@export var Bullet : PackedScene

func spawn_bullets(notePos : Vector2) -> void:
	print(notePos)
	var bullet = Bullet.instantiate()
	bullet.global_position = notePos
	
	var root = get_tree().get_root()
	var bulletGroup = root.get_node("Main/BulletGroup")
	bulletGroup.add_child(bullet)

