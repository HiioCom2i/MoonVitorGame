extends BehaviorNode
class_name ActionNode

var action_func: Callable = Callable() # Inicializa com um Callable vazio

func _init(action_func: Callable = Callable()): # O parâmetro também tem valor padrão
	self.action_func = action_func

func tick(agent) -> int:
	if action_func.is_valid(): # Verifica se o Callable é válido antes de chamar
		return action_func.call(agent)
	return Status.FAILURE
