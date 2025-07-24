class_name Package
extends RigidBody3D

signal package_delivered_successfully
signal package_delivery_failed(reason: String)

@export var package_name: String = "Unnamed Package"
var components: Array[PackageComponent] = []
var is_failed: bool = false

@onready var component_holder: Node3D = $ComponentHolder

func _ready() -> void:
	for child in component_holder.get_children():
		components.append(child)
		child.package_failed.connect(_on_component_failed)
		child.package_warning.connect(_on_component_warning)
		
		child.activate()


func activate_package():
	for component in components:
		component.activate()


func deactivate_package():
	for component in components:
		component.activate()


func _on_component_failed(reason: String):
	if not is_failed:
		is_failed = true
		package_delivery_failed.emit(reason)
		print("Package failed: ", reason)


func _on_component_warning(message: String):
	print("Package warning: ", message)


func deliver_package():
	if not is_failed:
		package_delivered_successfully.emit()
		print("Package delivered successfully!")
