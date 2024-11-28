# WhileSuccessDecorator.gd
extends BehaviorNode
class_name WhileSuccessDecorator

var child: BehaviorNode = null

func _init(child: BehaviorNode):
	self.child = child

func tick(agent) -> int:
	var status = child.tick(agent)
	if status == Status.SUCCESS:
		return Status.RUNNING
	return Status.FAILURE
