extends CharacterBody2D
class_name BaseCharacter

@export_category("Variables")
@export var _move_speed: float = 128.0

func _physics_process(_delta: float) -> void:
	var _direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	velocity = _direction * _move_speed
	move_and_slide()
	
	
