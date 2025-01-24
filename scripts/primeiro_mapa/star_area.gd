extends Node2D

@export var damage: int = 2
@export var visible_duration: float = 1.5  # Tempo antes de explodir
@export var explosion_radius: float = 100.0  # Tamanho da área de explosão

signal exploded

var has_exploded: bool = false

func _ready() -> void:
	$area.connect("body_entered", Callable(self, "_on_body_entered"))
	$area.monitoring = false
	await_visible_then_explode()

# Aguarda o tempo definido antes de explodir
func await_visible_then_explode() -> void:
	await get_tree().create_timer(visible_duration).timeout
	explode()

# Explode e emite o sinal
func explode() -> void:
	$area/sprite.visible = false  # Oculta o sprite
	has_exploded = true
	$area.monitoring = true  # Ativa a colisão para aplicar dano
	emit_signal("exploded")  # Emite o sinal de explosão
	await get_tree().create_timer(0.1).timeout
	queue_free()  # Remove o nó da cena

# Lida com dano ao jogador
func _on_body_entered(body: Node) -> void:
	if has_exploded:
		print("Aplicando dano ao jogador!")
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if body.has_method("is_death"):
			body.is_death()
