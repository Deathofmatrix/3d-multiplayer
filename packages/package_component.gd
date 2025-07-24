class_name PackageComponent
extends Node

signal package_failed(reason: String)
signal package_warning(reason: String)

var package_node: RigidBody3D
var is_active: bool = false


func _ready() -> void:
	package_node = get_parent().get_parent()


func activate():
	is_active = true
	_on_activate()


func deactivate():
	is_active = false
	_on_deactivate()


func _on_activate():
	pass


func _on_deactivate():
	pass
