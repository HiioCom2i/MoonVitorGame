extends Node2D

@export var star_area_scene: PackedScene  # Referência à cena `StarArea`
@export var star_spawn_interval: float = 1.0  # Intervalo entre spawns
@export var min_spawn_time: float = 3.0  # Tempo mínimo entre spawns
@export var max_spawn_time: float = 5.0  # Tempo máximo entre spawns
@export var max_attacks: int = 10  # Máximo de ataques na área
@export var collectible_scene: PackedScene  # Referência ao coletável

@onready var spawn_area: Area2D = $area
@onready var boss_arena_reference = $".."  # Referência à arena do boss
@onready var spawned_items: Node2D = $spawned_items

signal star_areas_finished

var qnt_ataques: int = 0
var active_star_areas: Array = []



func _ready() -> void:
	spawned_items = $listaAtaques if $listaAtaques else null

	if not spawned_items:
		print("Erro: Nó 'spawned_items' não foi encontrado na cena!")
	else:
		spawn_item_with_delay()

# Spawna um item com um atraso aleatório
func spawn_item_with_delay() -> void:
	while true:
		var delay = randf_range(min_spawn_time, max_spawn_time)
		await get_tree().create_timer(delay).timeout
		if qnt_ataques < max_attacks:
			spawn_item()

# Spawna o item dentro da área
func spawn_item() -> void:
	if collectible_scene:
		var item: Node2D = collectible_scene.instantiate()
		item.position = get_random_point_in_area()

		if spawned_items:
			spawned_items.add_child(item)
			boss_arena_reference.iniciando_ataques()
			qnt_ataques += 1
		else:
			print("Erro: 'spawned_items' não está definido!")


# Gera uma posição aleatória dentro da área
func get_random_point_in_area() -> Vector2:
	var collision_shape: CollisionShape2D = spawn_area.get_node("colisaoDaArea")
	if collision_shape.shape is RectangleShape2D:
		var extents = collision_shape.shape.extents
		var random_x = randf_range(-extents.x, extents.x)
		var random_y = randf_range(-extents.y, extents.y)
		return spawn_area.position + Vector2(random_x, random_y)
	return Vector2.ZERO

func decrease_qnt_ataques() -> void:
	qnt_ataques = qnt_ataques - 1
	print("qnt_ataques = " + str(qnt_ataques))

func spawn_star_areas() -> void:
	for i in range(6):  # Cria 6 áreas explosivas
		var delay = i * star_spawn_interval
		spawn_star_area_with_delay(delay)

# Cria uma área explosiva com atraso
func spawn_star_area_with_delay(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	spawn_star_area()

# Spawna uma única área explosiva
func spawn_star_area() -> void:
	if star_area_scene:
		var area = star_area_scene.instantiate()
		area.position = get_random_point_in_area()
		add_child(area)

		active_star_areas.append(area)
		area.connect("exploded", Callable(self, "_on_star_area_exploded"))
		print("Área de estrela spawnada e sinal conectado.")

		
func _on_star_area_exploded(area: Node) -> void:
	active_star_areas.erase(area)
	qnt_ataques -= 1  # Reduz o número de ataques ativos
	print("Área explodida! qnt_ataques = %d, active_star_areas restantes: %d" % [qnt_ataques, active_star_areas.size()])
	
	if active_star_areas.is_empty() and qnt_ataques == 0:
		print("Todas as áreas explodiram. Emitindo sinal 'star_areas_finished'.")
		emit_signal("star_areas_finished")
