extends Area2D

@export var area_id: String = ""  # Identificador único para cada área (por exemplo, "Area1")
@export var enemies: Array[CharacterBody2D]  # Lista de inimigos específicos dentro desta área

# Função para adicionar inimigos na lista da área
func add_enemy(enemy: CharacterBody2D) -> void:
	enemies.append(enemy)

# Função para ativar os inimigos na área quando o jogador entra
func activate_enemies() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):  # Verifica se o inimigo ainda existe
			if enemy.vivo == true:    
				if enemy.has_method("start_chasing"):
					enemy.start_chasing()

# Função para desativar os inimigos na área quando o jogador sai
func deactivate_enemies() -> void:
	var to_remove = []  # Lista para armazenar inimigos a serem removidos
	for enemy in enemies:
		if is_instance_valid(enemy):  # Verifica se o inimigo ainda existe
			if enemy.has_method("stop_chasing"):
				enemy.stop_chasing()

	# Remove todos os inimigos da lista
	#for enemy in to_remove:
		#enemies.erase(enemy)
