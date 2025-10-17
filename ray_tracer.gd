extends Node3D

@onready var texture: ColorRect = $ColorRect
@onready var camera: Camera3D = $Camera3D

@onready var schwarzschild_material: ShaderMaterial = preload("res://schwarzschild_material.tres")
@onready var kerr_newman_material: ShaderMaterial = preload("res://kerr_newman_material.tres")
@onready var alcubierre_material: ShaderMaterial = preload("res://alcubierre_material.tres")

func _ready() -> void:
	setup_schwarzschild()
	pass


func _process(delta: float) -> void:
	if texture.material:
		texture.material.set_shader_parameter("camera_position", camera.position)
		texture.material.set_shader_parameter("camera_rotation", camera.transform.basis)
		texture.material.set_shader_parameter("fov", camera.fov)



func setup_schwarzschild():
	$CanvasLayer/VBoxContainer/SchwarzschildParameters.show()
	$CanvasLayer/VBoxContainer/KerrNewmanParameters.hide()
	$CanvasLayer/VBoxContainer/AlcubierreParameters.hide()
	
	texture.material = schwarzschild_material
	
	var mass = texture.material.get_shader_parameter("mass")
	
	$CanvasLayer/VBoxContainer/SchwarzschildParameters/Label.text = "m: %.2f" % mass
	$CanvasLayer/VBoxContainer/SchwarzschildParameters/mass.value = mass
	
func setup_kerr_newman():
	$CanvasLayer/VBoxContainer/SchwarzschildParameters.hide()
	$CanvasLayer/VBoxContainer/KerrNewmanParameters.show()
	$CanvasLayer/VBoxContainer/AlcubierreParameters.hide()

	texture.material = kerr_newman_material

	var mass = texture.material.get_shader_parameter("mass")
	var a = texture.material.get_shader_parameter("a")
	var Q = texture.material.get_shader_parameter("Q")
	
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Mass/Label.text = "m: %.2f" % mass
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Mass/Mass.value = mass
	
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/A/Label.text = "a: %.2f" % a
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/A/A.value = a

	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Q/Label.text = "Q: %.2f" % Q
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Q/Q.value = Q


func setup_alcubierre():
	$CanvasLayer/VBoxContainer/SchwarzschildParameters.hide()
	$CanvasLayer/VBoxContainer/KerrNewmanParameters.hide()
	$CanvasLayer/VBoxContainer/AlcubierreParameters.show()
	
	texture.material = alcubierre_material
	
	var velocity = texture.material.get_shader_parameter("velocity")
	var R = texture.material.get_shader_parameter("R")
	var sigma = texture.material.get_shader_parameter("sigma")
	
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Velocity/Label.text = "v: %.2f" % velocity
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Velocity/Velocity.value = velocity
	
	$CanvasLayer/VBoxContainer/AlcubierreParameters/R/Label.text = "R: %.2f" % R
	$CanvasLayer/VBoxContainer/AlcubierreParameters/R/R.value = R
	
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Sigma/Label.text = "σ: %.2f" % sigma
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Sigma/Sigma.value = sigma
func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		setup_schwarzschild()
	if index == 1:
		setup_kerr_newman()
	if index == 2:
		setup_alcubierre()

func _on_schwarzschild_mass_value_changed(mass: float) -> void:
	schwarzschild_material.set_shader_parameter("mass", mass)
	$CanvasLayer/VBoxContainer/SchwarzschildParameters/Label.text = "m: %.2f" % mass
	$CanvasLayer/VBoxContainer/SchwarzschildParameters/mass.value = mass

func _on_kerr_newman_mass_value_changed(mass: float) -> void:
	kerr_newman_material.set_shader_parameter("mass", mass)
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Mass/Label.text = "m: %.2f" % mass
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Mass/Mass.value = mass

func _on_kerr_newman_a_value_changed(a: float) -> void:
	kerr_newman_material.set_shader_parameter("a", a)
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/A/Label.text = "a: %.2f" % a
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/A/A.value = a

func _on_kerr_newman_q_value_changed(Q: float) -> void:
	kerr_newman_material.set_shader_parameter("Q", Q)
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Q/Label.text = "Q: %.2f" % Q
	$CanvasLayer/VBoxContainer/KerrNewmanParameters/Q/Q.value = Q

func _on_alcubierre_velocity_value_changed(velocity: float) -> void:
	alcubierre_material.set_shader_parameter("velocity", velocity)
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Velocity/Label.text = "v: %.2f" % velocity
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Velocity/Velocity.value = velocity

func _on_alcubierre_r_value_changed(R: float) -> void:
	alcubierre_material.set_shader_parameter("R", R)
	$CanvasLayer/VBoxContainer/AlcubierreParameters/R/Label.text = "R: %.2f" % R
	$CanvasLayer/VBoxContainer/AlcubierreParameters/R/R.value = R

func _on_alcubierre_sigma_value_changed(sigma: float) -> void:
	alcubierre_material.set_shader_parameter("sigma", sigma)
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Sigma/Label.text = "σ: %.2f" % sigma
	$CanvasLayer/VBoxContainer/AlcubierreParameters/Sigma/Sigma.value = sigma
