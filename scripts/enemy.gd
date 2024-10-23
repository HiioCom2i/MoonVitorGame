extends CharacterBody2D

@onready var texture := $texture as Sprite2D
@export var limEsq: float
@export var limDir: float
@export var SPEED: float


var direction := -1

func _physics_process(delta: float) -> void:
	
	velocity.x = direction * SPEED * delta
	
	if position.x <= limDir:
		direction = 1
		texture.flip_h = true
	if position.x >= limEsq:
		direction = -1
		texture.flip_h = false
	#print(position.x)

	move_and_slide()
