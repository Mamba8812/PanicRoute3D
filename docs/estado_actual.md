# Estado Actual del Proyecto — Panic Route 3D

> **Fecha de levantamiento:** 15 de noviembre de 2026  
> **Rama Git activa:** `Union` (con cambios locales pendientes en `apuntar.gd`, `main.tscn`, `project.godot`, `puerta.gd` y `puerta.tscn`).

---

## 1. Configuración General del Motor

* **Motor:** Godot Engine `4.7` (perfil `GL Compatibility`).
* **Motor de Física 3D:** `Jolt Physics`.
* **Escena principal:** `res://main.tscn`.
* **Nombre en `project.godot`:** `"Juego del equipo (3D)"`.
* **Acciones de entrada (`InputMap`):**
  * `move_left`: `A` / Flecha izquierda
  * `move_right`: `D` / Flecha derecha
  * `move_up`: `W` / Flecha arriba
  * `move_down`: `S` / Flecha abajo
  * `puerta`: `E`
  * `disparar`: Clic izquierdo del ratón

---

## 2. Estructura de Carpetas

```text
Panic Route/                        # Raíz del repositorio Git
├── .gitignore                      # Ignora .godot/, exportaciones, binarios
├── README.md                       # Título y descripción breve (PanicRoute3D)
├── Concepto Videojuego 3D.pdf      # Documento conceptual original (Corte 1)
├── docs/                           # Documentación del proyecto
│   ├── README.md
│   ├── estado_actual.md
│   ├── concepto_videojuego.md
│   └── plan_desarrollo.md
└── Panic Route/                    # Raíz del proyecto Godot (res://)
    ├── project.godot               # Configuración del proyecto e InputMap
    ├── LEEME.txt                   # Notas de la plantilla base (Sesión 7)
    ├── icon.svg                    # Ícono del proyecto
    ├── main.tscn                   # Escena principal (nivel dummy + entidades)
    ├── puerta.tscn                 # Escena reutilizable de puerta
    ├── civil.tscn                  # Escena vacía (solo nodo raíz CharacterBody3D)
    ├── personaje.gd                # Control del jugador y pruebas automáticas
    ├── camara_sigue.gd             # Seguimiento suave de cámara 3D
    ├── apuntar.gd                  # Raycast desde mouse / cámara / personaje
    ├── civil.gd                    # IA básica de patrulla y persecución
    ├── puerta.gd                   # Animación vertical de puerta con Tween
    ├── accion_puerta.gd            # Máquina de estados para abrir puerta con 'E'
    ├── AccionPuerta.gd             # Script vacío (plantilla sin uso)
    └── personaje/                  # Assets 3D (Kenney Mini Characters, CC0)
        ├── LICENCIA Kenney (CC0).txt
        ├── character-male-a.glb    # Modelo usado por Personaje
        ├── character-male-d.glb    # Modelo usado por civil
        ├── character-female-b.glb  # Disponible, sin usar
        ├── character-female-e.glb  # Disponible, sin usar
        └── Textures/
            └── colormap.png        # Textura compartida
```

---

## 3. Elementos de Desarrollo Utilizados

* **Lenguaje:** 100% **GDScript** (7 archivos `.gd`, uno vacío).
* **Modelos 3D:** 4 archivos `.glb` de *Kenney Mini Characters* (CC0) con animaciones integradas (`idle`, `walk`). Actualmente solo se instancian 2 en `main.tscn`.
* **Geometría del escenario:** Construida íntegramente con primitivas nativas de Godot dentro de `main.tscn`:
  * `Suelo`: `StaticBody3D` con `PlaneMesh` (`30 × 30 m`) y `BoxShape3D`.
  * `Cajas`: 3 `StaticBody3D` con `BoxMesh` (`1 × 1 × 1 m`).
  * `Paredes`: 14 nodos `CSGBox3D` con `use_collision = true` formando un recinto de `16 × 16 m` con pasillos internos estrechos.
  * `Puertas`: 4 instancias de `puerta.tscn` (`BoxMesh` de `0.4 × 3 × 2 m`).
* **UI, Audio, Navegación y Shaders:** No existen todavía en el proyecto.

---

## 4. Funciones de cada Script y Escena

### `personaje.gd` (en `Personaje` dentro de `main.tscn`)
* `CharacterBody3D` con `speed = 3.0`, gravedad y cápsula de colisión (`radius = 0.35`, `height = 1.75`).
* Calcula el movimiento en el plano XZ relativo a `camara.global_basis`.
* Rota el personaje hacia la dirección de movimiento (`Basis.looking_at(direction)`) y alterna animaciones `walk` / `idle` (o `accion` si está asignada).
* Expone 3 variables "enchufe" (`multiplicador`, `empuje`, `accion`) para modificar su comportamiento desde scripts externos.
* Contiene un sistema de pruebas automáticas ejecutables desde el Inspector (`prueba`, `accion_prueba`).

### `camara_sigue.gd` (en `Camera3D` dentro de `main.tscn`)
* `top_level = true`, `distancia = Vector3(0, 12, 4)`, `suavizado = 3.0`.
* Sigue al `objetivo` (`Personaje`) aplicando `clamp` entre `limite_min = Vector2(-3, -10)` y `limite_max = Vector2(3, 10)`.

### `apuntar.gd` (nodo hijo `Apuntar` de `Personaje`)
* Lanza un `PhysicsRayQueryParameters3D` de hasta `alcance = 20.0 m` al presionar `disparar` (clic izquierdo), con `cadencia = 0.25 s`.
* Soporta 3 orígenes (`Personaje`, `Centro de la cámara`, `Mouse`); actualmente usa `Mouse` (`desde = 2`).
* Si el `collider` tiene `alternar()`, lo ejecuta inmediatamente; si tiene `recibir_golpe()`, le envía `25`.

### `civil.gd` (en `civil` dentro de `main.tscn`)
* `CharacterBody3D` con cápsula (`radius = 0.35`, `height = 1.75`), `rapidez = 2.0`, `radio_ver = 6.0`, `radio_perder = 9.0`.
* Máquina de estados:
  * `PATRULLA`: camina entre `puntos` (`(-6, 0, -3)` y `(6, 0, -3)`). Si el jugador está a `< 6.0 m`, pasa a `PERSEGUIR`.
  * `PERSEGUIR`: camina en línea recta hacia `objetivo.global_position` sin detenerse ni guardar distancia mínima, hasta que el jugador se aleja a `> 9.0 m`.

### `puerta.gd` y `accion_puerta.gd` (en `puerta.tscn`)
* `puerta.gd` (`StaticBody3D`): al llamar `alternar()`, anima `position:y` `-3.0 m` (abrir) o vuelve a `pos_inicial_y` (cerrar) con un `Tween` de `duracion = 0.5 s`.
* `accion_puerta.gd` (nodo hijo `AccionPuerta`): máquina de estados (`LISTA`, `ACTIVA`, `RECARGA`) activada con `E` (`puerta`).
  * Verifica en `puede()` que `Personaje` exista en `current_scene`, esté a `< 2.5 m` y la puerta no esté en movimiento.
  * Al activarse, espera `duracion = 1.5 s` antes de llamar a `pj.alternar()` y luego entra en `RECARGA` de `1.0 s`.

### Archivos sin uso / incompletos
* `AccionPuerta.gd`: plantilla vacía generada por Godot.
* `civil.tscn`: escena con solo un nodo `CharacterBody3D` vacío (el civil real fue armado directamente en `main.tscn`).

---

## 5. Diagnóstico Técnico (Fortalezas y Problemas)

### Fortalezas
* Uso de escenas empaquetadas para objetos repetibles (`puerta.tscn`).
* Patrón de composición con nodos hijos (`Apuntar`, `AccionPuerta`) y máquinas de estados legibles (`enum` + `match`).
* Uso de `Tween` para transiciones suaves y `Jolt Physics`.

### Problemas detectados
1. **Estructura plana:** Todos los scripts y escenas están mezclados en la raíz `res://`.
2. **Entidades acopladas a `main.tscn`:** `Personaje` y `civil` no son escenas `.tscn` reutilizables; si se cambia de mapa habrá que duplicarlos manualmente.
3. **Conflicto de diseño en puertas:** `apuntar.gd` (clic izquierdo) llama a `alternar()` a 20 m saltándose el retardo y la regla de proximidad de `accion_puerta.gd` (`E`). Además, `accion_puerta.gd` suma `1.5 s` de espera + `0.5 s` de animación + `1.0 s` de recarga (`3.0 s` por ciclo).
4. **IA del civil sin navegación ni distancia de parada:** `civil.gd` persigue en línea recta desde `6.0 m` (casi la mitad del mapa actual) y colisiona directamente contra el jugador y contra paredes sin rodearlas (`NavigationAgent3D` ausente).
5. **Escala del mapa dummy y nodos duplicados:** El recinto mide `16 × 16 m` con pasillos de `~2.4 m` entre muros (`-1.2` a `1.2` en el pasillo central) y cápsulas de diámetro `0.7 m`, lo que genera bloqueos frecuentes. Además, en `main.tscn` hay muros duplicados en la misma posición (`Muro_Horizontal3` y `Muro_Horizontal12`; `Muro_Horizontal6` y `Muro_Horizontal7`).
6. **Grupos ambiguos:** En `puerta.tscn`, tanto el `StaticBody3D` como su hijo `AccionPuerta` tienen el grupo `"puertas"`.
7. **Archivo muerto:** `AccionPuerta.gd` debe eliminarse para evitar confusiones con `accion_puerta.gd`.
