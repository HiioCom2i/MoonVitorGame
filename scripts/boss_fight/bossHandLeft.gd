extends CharacterBody2D

@onready var hand_anim: AnimatedSprite2D = $handAnim
signal attack_finished


func _ready() -> void:
	hand_anim.scale.x *= -1
	hand_anim.connect("animation_finished", Callable(self, "_on_hand_anim_animation_finished"))
	hand_anim.play("idle")
	print("Conectado ao sinal 'animation_finished' da animação.")
	
func attack():
	if hand_anim.sprite_frames.has_animation("attack"):
		print("Tocando animação 'attack'.")
		hand_anim.play("attack")  # Toca a animação de ataque
	else:
		print("A animação 'attack' não existe no handAnim!")
		
func attackStar():
	if hand_anim.sprite_frames.has_animation("death"):
		print("Tocando animação 'death'.")
		hand_anim.play("death")  # Toca a animação de ataque
	else:
		print("A animação 'death' não existe no handAnim!")


func _process(delta: float) -> void:
	pass


func _on_hand_anim_animation_finished() -> void:
	# Verifica se a animação finalizada é "attack"
	if hand_anim.animation == "attack":
		emit_signal("attack_finished")  # Emite o sinal apenas para a animação "attack"
		print("Emitido sinal 'attack_finished' da mão direita.")
	
	# Se a animação "idle" existe, retorna para ela
	if hand_anim.sprite_frames.has_animation("idle"):
		hand_anim.play("idle")  # Retorna para a animação "idle"
		print("Retornando para a animação 'idle'")
	else:
		print("A animação 'idle' não existe no handAnim!")
