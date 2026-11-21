extends Node

enum Estado { LISTA, ACTIVA, RECARGA }

@export var tecla = "puerta"
@export var duracion = 0.0
@export var recarga = 0.35

@onready var pj = get_parent() # El padre es la Puerta (StaticBody3D)
var estado = Estado.LISTA
var tiempo = 0.0


func _physics_process(delta):
	tiempo -= delta
	match estado:
		Estado.LISTA:
			if Input.is_action_just_pressed(tecla) and puede():
				empezar()
		Estado.ACTIVA:
			if tiempo <= 0.001:
				terminar()
		Estado.RECARGA:
			if tiempo <= 0.001:
				estado = Estado.LISTA


func puede():
	var personaje = get_tree().get_first_node_in_group("jugador")
	if not personaje:
		personaje = get_tree().current_scene.get_node_or_null("Personaje")
	if not personaje:
		return false

	# Medimos desde el centro real de la hoja de la puerta (offset z = 0.85)
	var centro_puerta = pj.to_global(Vector3(0, 0, 0.85)) if pj is Node3D else pj.global_position
	var distancia = min(
		pj.global_position.distance_to(personaje.global_position),
		centro_puerta.distance_to(personaje.global_position)
	)

	var esta_cerca = distancia < 2.8
	var puerta_quieta = not pj.get("en_movimiento") if pj.has_method("get") else true

	return esta_cerca and puerta_quieta


func empezar():
	estado = Estado.ACTIVA
	tiempo = duracion


func terminar():
	estado = Estado.RECARGA
	tiempo = recarga

	if pj.has_method("alternar"):
		pj.alternar()
