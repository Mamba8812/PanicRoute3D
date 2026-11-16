extends CharacterBody3D

@export var camara: Camera3D
@export var speed = 3.5
@onready var anim = $Modelo/AnimationPlayer

# Enchufes: otros scripts (las acciones del juego) cambian estas tres variables.
var multiplicador = 1.0     # 1 = rapidez normal, 0.5 = la mitad, 0 = quieto
var empuje = Vector3.ZERO   # velocidad extra en m/s (dash, retroceso)
var accion = ""             # animación de la acción; "" = ninguna

# Fila de rescate: cada civil recogido sigue al último de la fila.
var cola_rescate: Array[Node3D] = []
var salud = 3
var _invulnerable = 0.0


func obtener_ultimo_en_fila(civil: Node3D) -> Node3D:
	cola_rescate = cola_rescate.filter(func(n): return is_instance_valid(n))
	var lider: Node3D = self if cola_rescate.is_empty() else cola_rescate[-1]
	if not cola_rescate.has(civil):
		cola_rescate.append(civil)
	return lider


func salir_de_fila(civil: Node3D):
	var idx = cola_rescate.find(civil)
	if idx == -1:
		return
	cola_rescate.remove_at(idx)
	# Re-enlaza al civil que venía detrás con el nuevo líder anterior
	for i in range(cola_rescate.size()):
		var c = cola_rescate[i]
		if is_instance_valid(c):
			c.objetivo = self if i == 0 else cola_rescate[i - 1]


func recibir_dano_fuego(origen_fuego: Vector3):
	if _invulnerable > 0.0:
		return
	_invulnerable = 1.2
	salud -= 1
	var dir = (global_position - origen_fuego)
	dir.y = 0.0
	if dir.length() > 0.01:
		empuje = dir.normalized() * 6.0
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm != null:
		gm.actualizar_salud(salud)


func _ready():
	if camara == null:
		camara = get_viewport().get_camera_3d()


func _physics_process(delta):
	if _invulnerable > 0.0:
		_invulnerable -= delta
	empuje = empuje.lerp(Vector3.ZERO, 8.0 * delta)
	velocity += get_gravity() * delta

	var input_dir = Input.get_vector("move_left", "move_right",
		"move_up", "move_down")
	var entrada = Vector3(input_dir.x, 0.0, input_dir.y)
	var direction = entrada
	if camara != null:
		direction = camara.global_basis * entrada
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * speed * multiplicador + empuje.x
	velocity.z = direction.z * speed * multiplicador + empuje.z

	if direction.length() > 0:
		basis = Basis.looking_at(direction)
	if accion != "":
		anim.play(accion)
	elif direction.length() > 0:
		anim.play("walk")
	else:
		anim.play("idle")

	move_and_slide()
	_prueba()


# ---------------------------------------------------------------------------
# PRUEBAS AUTOMÁTICAS. En el Inspector del Personaje elijan "Prueba"
# (y, si la prueba usa una acción, escriban su nombre en "Accion Prueba").
# ---------------------------------------------------------------------------
@export_enum("Ninguna", "Avanzar 60 cuadros", "Avanzar 60 y soltar", "Avanzar y la acción desde el cuadro 30", "Mantener la acción 2 s", "Avanzar con la acción 60 cuadros", "Diagonal W+D 60 cuadros") var prueba = 0
@export var accion_prueba = ""
var _cuadro = 0
var _termino = false
var _y_max = 0.0
var _cuadro_max = 0


func _prueba():
	if prueba == 0 or _termino:
		return
	_cuadro += 1
	var avanzar = "move_up"
	var lado = "move_right"
	if _cuadro == 1:
		if prueba <= 3 or prueba == 5:
			_apretar(avanzar)
		if prueba == 4 or prueba == 5:
			_apretar(accion_prueba)
		if prueba == 6:
			_apretar(avanzar)
			_apretar(lado)
		return
	var n = _cuadro - 1
	if prueba == 3 and n == 30:
		_apretar(accion_prueba)
	if prueba == 2 and n == 60:
		Input.action_release(avanzar)
	var marcas = []
	if prueba == 1 or prueba == 5:
		marcas = [1, 2, 3, 5, 10, 15, 20, 30, 60]
	elif prueba == 2:
		marcas = [59, 60, 61, 62, 63, 65, 70, 80, 90]
	elif prueba == 3:
		marcas = [29, 30, 31, 32, 33, 35, 40, 45, 50, 60, 75, 90]
	elif prueba == 6:
		marcas = [1, 30, 60]
	else:
		marcas = [1, 15, 30, 45, 60, 75, 90, 105, 120, 135, 150]
	if n in marcas:
		print("[prueba] cuadro ", n, ": ", _resumen())
	_cambios(n)
	if global_position.y > _y_max + 0.0001:
		_y_max = global_position.y
		_cuadro_max = n
	if n == marcas[-1]:
		Input.action_release(avanzar)
		Input.action_release(lado)
		_soltar(accion_prueba)
		_termino = true
		if _y_max > 0.01:
			print("[prueba] altura máxima ", snappedf(_y_max, 0.01), " en el cuadro ", _cuadro_max)


func _resumen():
	var t = "posición " + str(global_position.snappedf(0.01))
	t += " · rapidez " + str(snappedf(Vector2(velocity.x, velocity.z).length(), 0.01))
	t += " · y " + str(snappedf(global_position.y, 0.01))
	t += " · animación " + str(anim.current_animation)
	for nodo in _con_estado():
		t += " · " + str(nodo.name) + ".estado " + _nombre(nodo)
	return t


var _antes = {}


func _cambios(n):
	for nodo in _con_estado():
		var e = _nombre(nodo)
		if _antes.has(nodo) and _antes[nodo] != e:
			print("[prueba] cuadro ", n, ": ", nodo.name, ".estado cambia a ", e)
		_antes[nodo] = e


func _con_estado():
	var lista = []
	for nodo in [self] + get_children() + get_tree().get_nodes_in_group("probar"):
		if nodo.get_script() != null and "estado" in nodo:
			lista.append(nodo)
	return lista


func _nombre(nodo):
	var nombres = nodo.get_script().get_script_constant_map().get("Estado", {})
	for k in nombres:
		if nombres[k] == nodo.estado:
			return k
	return str(nodo.estado)


func _apretar(a):
	if a == "":
		print("[prueba] escriban el nombre de la acción en 'Accion Prueba'")
	elif not InputMap.has_action(a):
		print("[prueba] falta la acción '", a, "' en el Input Map")
	else:
		Input.action_press(a)


func _soltar(a):
	if a != "" and InputMap.has_action(a):
		Input.action_release(a)
