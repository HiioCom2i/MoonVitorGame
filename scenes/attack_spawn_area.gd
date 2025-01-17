extends Node2D

# Tempo entre spawns (mínimo e máximo)
@export var min_spawn_time: float = 3.0
@export var max_spawn_time: float = 5.0

# Máximo de ataques na área
@export var max_attacks = 10

var qnt_ataques = 0

# Referência para o item coletável (cena)
@export var collectible_scene: PackedScene

# Referência à área de spawn
@onready var spawn_area: Area2D = $area

# Nodo para armazenar os itens spawnados
@export var spawned_items: Node2D

@onready var boss_arena_reference = $".."



func _ready() -> void:
	# Inicia o processo de spawn
	spawn_item_with_delay()

# Spawna um item com um atraso aleatório
func spawn_item_with_delay() -> void:
	while true:
		var delay = randf_range(min_spawn_time, max_spawn_time)
		await get_tree().create_timer(delay).timeout
		if qnt_ataques <= max_attacks:
			spawn_item()

# Spawna o item dentro da área
func spawn_item() -> void:
	if collectible_scene:
		# Instancia o item coletável
		var item: Node2D = collectible_scene.instantiate()
		
		# Determina um ponto aleatório dentro da área
		var spawn_position: Vector2 = get_random_point_in_area()
		item.position = spawn_position

		# Adiciona o item à cena
		spawned_items.add_child(item)
		boss_arena_reference.iniciando_ataques()
		qnt_ataques += 1

# Gera uma posição aleatória dentro da área
func get_random_point_in_area() -> Vector2:
	# Obtém os limites da colisão da área
	var collision_shape: CollisionShape2D = spawn_area.get_node("colisaoDaArea")
	if collision_shape.shape is RectangleShape2D:
		var extents: Vector2 = collision_shape.shape.extents
		var random_x: float = randf_range(-extents.x, extents.x)
		var random_y: float = randf_range(-extents.y, extents.y)
		return spawn_area.position + Vector2(random_x, random_y)
	return Vector2.ZERO

func decrease_qnt_ataques() -> void:
	qnt_ataques = qnt_ataques - 1
	print("qnt_ataques = " + str(qnt_ataques))
