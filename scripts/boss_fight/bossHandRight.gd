extends CharacterBody2D

@onready var hand_anim: AnimatedSprite2D = $handAnim


func _ready() -> void:
	
	hand_anim.play("idle") 

func attack():
	hand_anim.stop()


func _process(delta: float) -> void:
	pass
