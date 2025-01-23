extends AnimatedSprite2D

@onready var hand_anim: AnimatedSprite2D = $"."


func _ready() -> void:
	
	hand_anim.play("idle") 



func _process(delta: float) -> void:
	pass
