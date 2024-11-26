# ConditionNode.gd
extends BehaviorNode
class_name ConditionNode

var condition_func: Callable = Callable()

func _init(condition_func: Callable = Callable()):
	self.condition_func = condition_func

func tick(agent) -> int:
	if condition_func.is_valid() and condition_func.call(agent):
		return Status.SUCCESS
	return Status.FAILURE
