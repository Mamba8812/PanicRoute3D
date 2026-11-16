extends Node3D

@onready var base: MeshInstance3D = $Base
@onready var llamas: CPUParticles3D = $ParticulasLlamas
@onready var humo: CPUParticles3D = $ParticulasHumo
@onready var chispas: CPUParticles3D = $ParticulasChispas
@onready var luz: OmniLight3D = $OmniLight3D
@onready var zona: Area3D = $ZonaPeligro
@onready var obstaculo: NavigationObstacle3D = $NavigationObstacle3D

@export var tiempo_preaviso = 3.0

var activo = false
var _t = 0.0
var _restante_preaviso = 0.0


func _ready():
	zona.body_entered.connect(_on_body_entered)
	if tiempo_preaviso > 0.0:
		_restante_preaviso = tiempo_preaviso
		activo = false
		llamas.emitting = false
		chispas.emitting = false
		humo.emitting = true
		obstaculo.avoidance_enabled = false
		luz.light_color = Color(1.0, 0.65, 0.05, 1.0)
	else:
		_activar_fuego()


func _process(delta):
	_t += delta * 6.0
	if not activo:
		_restante_preaviso -= delta
		base.visible = int(_t * 2.0) % 2 == 0
		luz.light_energy = 1.1 + sin(_t * 3.0) * 0.6
		if _restante_preaviso <= 0.0:
			_activar_fuego()
		return

	luz.light_energy = 2.8 + sin(_t * 1.7) * 0.55 + cos(_t * 2.9) * 0.25


func _activar_fuego():
	activo = true
	base.visible = true
	llamas.emitting = true
	humo.emitting = true
	chispas.emitting = true
	obstaculo.avoidance_enabled = true
	luz.light_color = Color(1.0, 0.42, 0.06, 1.0)
	for body in zona.get_overlapping_bodies():
		_on_body_entered(body)


func _on_body_entered(body: Node3D):
	if not activo:
		return
	if body.is_in_group("civiles") and body.has_method("eliminar_por_fuego"):
		if body.eliminar_por_fuego():
			var gm = get_tree().get_first_node_in_group("game_manager")
			if gm != null:
				gm.registrar_baja()
	elif body.is_in_group("jugador") and body.has_method("recibir_dano_fuego"):
		body.recibir_dano_fuego(global_position)
