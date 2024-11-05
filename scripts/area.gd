extends Area2D

@export var area_id: String = ""  # Identificador único para cada área (por exemplo, "Area1")
@export var enemies: Array[CharacterBody2D]  # Lista de inimigos específicos dentro desta área

# Função para ativar os inimigos na área quando o jogador entra
func activate_enemies() -> void:
	for enemy in enemies:
		if enemy.has_method("start_chasing"):
			enemy.start_chasing()

# Função para desativar os inimigos na área quando o jogador sai
func deactivate_enemies() -> void:
	for enemy in enemies:
		if enemy.has_method("stop_chasing"):
			enemy.stop_chasing()
