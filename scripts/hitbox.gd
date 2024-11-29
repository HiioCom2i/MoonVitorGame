extends Area2D

@export var area_script: Node


func _on_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body.name == "player" and body.canAttack: 
		owner.vivo = false
		owner.visible = false
		monitoring = false
		monitorable = false
		
		# Verifique se o CollisionShape2D existe antes de tentar desabilitar
		if is_instance_valid(owner) and owner is CharacterBody2D:
			var collision_shape = $CollisionShape2D  # Obtenha a referência para o CollisionShape2D
			if collision_shape:  # Verifica se o CollisionShape2D existe
				collision_shape.disabled = true  # Desabilita a colisão do inimigo

			# Alternativamente, se você quiser desabilitar as camadas de colisão
			owner.set_deferred("collision_layer", 0)  # Desativa a camada de colisão
			owner.set_deferred("collision_mask", 0)   # Desativa a máscara de colisão


		
