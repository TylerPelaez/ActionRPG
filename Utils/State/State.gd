"""
Base interface for all states: it doesn't do anything in itself
but forces us to pass the right arguments to the methods below
and makes sure every State object had all of these methods.
"""
extends Node
class_name State

# warning-ignore:unused_signal
signal finished(next_state_name)

func enter():
	return

func exit():
	return

func update(delta):
	return

func _on_animation_finished(anim_name):
	return
