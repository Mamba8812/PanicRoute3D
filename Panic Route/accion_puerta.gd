extends Node

@export var tecla = "puerta"
@onready var pj = get_parent()
var usos = 0

func _physics_process(delta):
	if Input.is_action_just_pressed(tecla):
		usos += 1
		print("empieza: ", tecla, " · uso número ", usos)
		var golpe = lanzar_rayo()
		if not golpe.is_empty():
			var objeto = golpe.collider
			if objeto.has_method("alternar"):
				objeto.alternar()

func lanzar_rayo():
	var cam = get_viewport().get_camera_3d()
	var punto = get_viewport().get_mouse_position()
	var origen = cam.project_ray_origin(punto)
	var hacia = origen + cam.project_ray_normal(punto) * 20.0
	var consulta = PhysicsRayQueryParameters3D.create(origen, hacia)
	consulta.exclude = [pj.get_rid()]
	return pj.get_world_3d().direct_space_state.intersect_ray(consulta)
