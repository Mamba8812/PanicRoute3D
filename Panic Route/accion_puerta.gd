extends Node

enum Estado { LISTA, ACTIVA, RECARGA }

@export var tecla = "puerta"
@export var duracion = 1.5
@export var recarga = 1.0

@onready var pj = get_parent()
var estado = Estado.LISTA
var tiempo = 0.0

func _physics_process(delta):
	tiempo -= delta
	match estado:
		Estado.LISTA:
			if Input.is_action_just_pressed(tecla):
				var personaje = get_tree().current_scene.get_node_or_null("Personaje")
				if personaje:
					var distancia = pj.global_position.distance_to(personaje.global_position)                
					if distancia < 2.0:
						empezar()
		Estado.ACTIVA:
			if tiempo <= 0.001:
				terminar()
		Estado.RECARGA:
			if tiempo <= 0.001:
				estado = Estado.LISTA

func empezar():
	estado = Estado.ACTIVA
	tiempo = duracion
	print("empieza: ", tecla)

	if pj.has_method("alternar"):
		pj.alternar()

func terminar():
	estado = Estado.RECARGA
	tiempo = recarga
	print("termina: ", tecla)
