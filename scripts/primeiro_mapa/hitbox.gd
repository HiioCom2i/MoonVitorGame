extends Area2D

@export var area_script: Node


func _on_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body.name == "player" and body.canAttack: 
		owner.queue_free()


		
