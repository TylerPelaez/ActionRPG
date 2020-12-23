extends Node
# This is a singlton

# For calling into the dialog box
signal event_triggered(eventName)

var events = {}

func add_event(eventName: String) -> void:
	if !events.has(eventName):
		events[eventName] = []

func trigger(eventName: String, args: Array = []) -> void:
	assert(events.has(eventName))
	
	emit_signal("event_triggered", eventName)
	
	for callback in events[eventName]:
		if args == null || args.empty():
			callback.call_func()
		else:
			callback.call_funcv(args)

func subscribe(eventName: String, callback: FuncRef) -> void:
	add_event(eventName)
	events[eventName].append(callback)

func clear():
	events.clear()
