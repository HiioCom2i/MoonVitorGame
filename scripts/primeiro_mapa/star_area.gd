extends Node2D

@export var damage: int = 10
@export var visible_duration: float = 1.5  # Tempo antes de explodir
@export var explosion_radius: float = 100.0  # Tamanho da área de explosão

signal exploded

func _ready() -> void:
	$area/colisao.shape.radius = explosion_radius
	$area.connect("body_entered", Callable(self, "_on_body_entered"))
	await_visible_then_explode()

# Aguarda o tempo definido antes de explodir
func await_visible_then_explode() -> void:
	await get_tree().create_timer(visible_duration).timeout
	explode()

# Explode e emite o sinal
func explode() -> void:
	$area/sprite.visible = false  # Oculta a área visual após a explosão
	emit_signal("exploded")
	queue_free()  # Remove a área da cena

# Lida com dano ao jogador
func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
