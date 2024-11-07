extends Area2D

@export var area_script: Node


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player": 
		owner.vivo = false
		owner.visible = false
		monitoring = false
		monitorable = false
		
