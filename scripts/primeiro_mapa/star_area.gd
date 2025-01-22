extends Node2D

@export var damage: int = 2
@export var visible_duration: float = 1.5  # Tempo antes de explodir
@export var explosion_radius: float = 100.0  # Tamanho da área de explosão

signal exploded

var has_exploded: bool = false  # Controle do estado da explosão

func _ready() -> void:
	#$area/colisao.shape.radius = explosion_radius
	$area.connect("body_entered", Callable(self, "_on_body_entered"))
	$area.monitoring = false  # Área desativada inicialmente
	await_visible_then_explode()

# Aguarda o tempo definido antes de explodir
func await_visible_then_explode() -> void:
	await get_tree().create_timer(visible_duration).timeout
	explode()

# Explode e emite o sinal
func explode() -> void:
	$area/sprite.visible = false  # Oculta a área visual após a explosão
	has_exploded = true  # Define o estado como explodido
	$area.monitoring = true  # Ativa a área de colisão
	emit_signal("exploded")
	# Adiciona um pequeno atraso antes de remover a área
	await get_tree().create_timer(0.1).timeout
	queue_free()  # Remove a área da cena

# Lida com dano ao jogador
func _on_body_entered(body: Node) -> void:
	if has_exploded:  # Aplica dano apenas após a explosão
		print("Aplicando dano ao jogador!")
		if body.has_method("take_damage"):
			body.take_damage(damage)
			if body.has_method("is_death"):
				body.is_death()
