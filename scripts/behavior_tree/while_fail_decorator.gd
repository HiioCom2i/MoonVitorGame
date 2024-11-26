# WhileFailDecorator.gd
extends BehaviorNode
class_name WhileFailDecorator

var child: BehaviorNode = null

func _init(child: BehaviorNode):
	self.child = child

func tick(agent) -> int:
	var status = child.tick(agent)
	if status == Status.FAILURE:
		return Status.RUNNING
	return Status.SUCCESS
