extends CharacterBody3D

enum Estado { ESPERANDO, SIGUIENDO, EVACUADO, ELIMINADO }

@export var objetivo: Node3D
@export var rapidez = 3.7
@export var distancia_parada = 1.15
@export var radio_separacion = 0.7

@onready var anim = $Modelo/AnimationPlayer
@onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")
@onready var zona_recogida: Area3D = get_node_or_null("ZonaRecogida")
@onready var icono_alerta: Node3D = get_node_or_null("IconoAlerta")

var estado = Estado.ESPERANDO
var _tiempo_atascado = 0.0
var _tiempo_desatasco = 0.0
var _pos_anterior = Vector3.ZERO


func _ready():
	_pos_anterior = global_position
	if zona_recogida != null:
		zona_recogida.body_entered.connect(_on_zona_recogida_body_entered)


func _on_zona_recogida_body_entered(body: Node3D):
	if estado == Estado.ESPERANDO and body.is_in_group("jugador"):
		recoger(body)


func recoger(jugador: Node3D):
	if estado != Estado.ESPERANDO:
		return
	if jugador.has_method("obtener_ultimo_en_fila"):
		objetivo = jugador.obtener_ultimo_en_fila(self)
	else:
		objetivo = jugador
	estado = Estado.SIGUIENDO
	if icono_alerta != null:
		icono_alerta.visible = false


func evacuar() -> bool:
	if estado == Estado.EVACUADO or estado == Estado.ELIMINADO:
		return false
	estado = Estado.EVACUADO
	_desvincular_fila()
	queue_free()
	return true


func eliminar_por_fuego() -> bool:
	if estado == Estado.EVACUADO or estado == Estado.ELIMINADO:
		return false
	estado = Estado.ELIMINADO
	_desvincular_fila()
	queue_free()
	return true


func _desvincular_fila():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador != null and jugador.has_method("salir_de_fila"):
		jugador.salir_de_fila(self)


func _physics_process(delta):
	if _tiempo_desatasco > 0.0:
		_tiempo_desatasco -= delta
		collision_mask = 0
		global_position.y = 0.1
		velocity.y = 0.0
	else:
		collision_mask = 1
		velocity += get_gravity() * delta

	match estado:
		Estado.ESPERANDO:
			velocity.x = 0.0
			velocity.z = 0.0
			anim.play("idle")

		Estado.SIGUIENDO:
			if not is_instance_valid(objetivo):
				objetivo = get_tree().get_first_node_in_group("jugador")
			if not is_instance_valid(objetivo):
				velocity.x = 0.0
				velocity.z = 0.0
				anim.play("idle")
				move_and_slide()
				return

			var distancia = _distancia_plana(global_position, objetivo.global_position)
			if distancia <= distancia_parada:
				_tiempo_atascado = 0.0
				var sep = _fuerza_separacion()
				velocity.x = sep.x
				velocity.z = sep.z
				if sep.length() > 0.1:
					anim.play("walk")
				else:
					anim.play("idle")
			else:
				var destino = objetivo.global_position
				# Si está cerca (< 3.5 m) o en modo desatasco, seguir directo al líder para no quedarse pegado a waypoints de muebles
				if _tiempo_desatasco <= 0.0 and distancia > 3.5 and nav_agent != null and NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) > 0:
					nav_agent.target_position = objetivo.global_position
					if not nav_agent.is_navigation_finished():
						destino = nav_agent.get_next_path_position()

				var rapidez_actual = rapidez * (1.3 if distancia > 3.2 else 1.0)
				_ir_a(destino, rapidez_actual)

				# Detección de atasco contra muebles o esquinas
				var avance = _distancia_plana(global_position, _pos_anterior)
				if avance < rapidez_actual * delta * 0.35 or is_on_wall():
					_tiempo_atascado += delta
					if is_on_wall():
						_deslizar_obstaculo(objetivo.global_position, rapidez_actual)
					if _tiempo_atascado > 0.45:
						_tiempo_desatasco = 0.45
						_tiempo_atascado = 0.0
				else:
					_tiempo_atascado = max(0.0, _tiempo_atascado - delta * 2.0)

	_pos_anterior = global_position
	move_and_slide()


func _deslizar_obstaculo(meta: Vector3, vel: float):
	var normal = get_wall_normal()
	normal.y = 0.0
	if normal.length() < 0.01:
		return
	normal = normal.normalized()
	var hacia = (meta - global_position)
	hacia.y = 0.0
	if hacia.length() < 0.01:
		return
	var dir_deslizar = (hacia.normalized() - normal * hacia.normalized().dot(normal)) + normal * 0.35
	if dir_deslizar.length() > 0.01:
		dir_deslizar = dir_deslizar.normalized()
		velocity.x = dir_deslizar.x * vel
		velocity.z = dir_deslizar.z * vel


func _fuerza_separacion() -> Vector3:
	var empuje = Vector3.ZERO
	for otro in get_tree().get_nodes_in_group("civiles"):
		if otro == self or not is_instance_valid(otro):
			continue
		var diff = global_position - otro.global_position
		diff.y = 0.0
		var d = diff.length()
		if d > 0.001 and d < radio_separacion:
			empuje += diff.normalized() * ((radio_separacion - d) / radio_separacion) * 2.0
	return empuje


func _distancia_plana(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _ir_a(p: Vector3, vel: float):
	var hacia = p - global_position
	hacia.y = 0.0
	if hacia.length() < 0.05:
		velocity.x = 0.0
		velocity.z = 0.0
		anim.play("idle")
		return
	var dir = hacia.normalized()
	velocity.x = dir.x * vel
	velocity.z = dir.z * vel
	basis = Basis.looking_at(dir)
	anim.play("walk")
