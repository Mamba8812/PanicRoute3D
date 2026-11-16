extends Node

enum Estado { LISTA, RECARGA }

@export var tecla = "puerta"
@export var recarga = 0.25

@onready var puerta = get_parent()
@onready var zona: Area3D = puerta.get_node_or_null("ZonaInteraccion")

var estado = Estado.LISTA
var tiempo = 0.0
var _jugador_cerca = false


func _ready():
	if zona != null:
		zona.body_entered.connect(_on_body_entered)
		zona.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D):
	if body.is_in_group("jugador"):
		_jugador_cerca = true


func _on_body_exited(body: Node3D):
	if body.is_in_group("jugador"):
		_jugador_cerca = false


func _physics_process(delta):
	match estado:
		Estado.LISTA:
			if Input.is_action_just_pressed(tecla) and _puede():
				_activar()
		Estado.RECARGA:
			tiempo -= delta
			if tiempo <= 0.0:
				estado = Estado.LISTA


func _puede() -> bool:
	var puerta_quieta = not puerta.get("en_movimiento")
	if not puerta_quieta:
		return false
	if zona != null:
		return _jugador_cerca
	# Fallback por distancia si no existe ZonaInteraccion
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return false
	return puerta.global_position.distance_to(jugador.global_position) < 2.8


func _activar():
	estado = Estado.RECARGA
	tiempo = recarga
	if puerta.has_method("alternar"):
		puerta.alternar()
