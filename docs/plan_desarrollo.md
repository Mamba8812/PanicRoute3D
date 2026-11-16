# Análisis del Concepto y Plan de Desarrollo — Panic Route 3D

## 1. Análisis del Concepto (`Concepto Videojuego 3D.pdf`)

El documento conceptual (Corte 1) define **Panic Route 3D** con una identidad muy clara:

* **Género:** Gestión de Flujo y Evacuación en Tiempo Real (RTS Táctico / Puzle de Emergencia), inspirado en *Mini Motorways* + *Overcooked! 2* + *Clash Royale*.
* **Fantasía y Rol:** El jugador es un **operador remoto** en una sala de control que manipula puertas cortafuegos para redirigir multitudes de civiles hacia zonas seguras mientras el fuego destruye el edificio.
* **Mecánicas numéricas clave del documento:**
  * **Fuego:** Avanza 1 casilla cada `3 s`, convirtiéndola en obstáculo letal permanente.
  * **Congestión:** Si se acumulan `≥ 5` civiles en una celda, su velocidad cae un `50%` (`1.5 m/s` → `0.75 m/s`) y se tornan ámbar (`#FFB703`).
  * **Conmutación de puertas:** Retardo intencional de `1.5 s` tras hacer clic, con parpadeo visual previo.
  * **Victoria / Derrota:** Victoria al evacuar el `100%` de civiles; derrota si el fuego alcanza a `> 20%` de ellos.
* **Estética:** Low Poly plano, vista cenital, paleta de 5 colores (`#2B2D42`, `#8D99AE`, `#EF233C`, `#06D6A0`, `#3A86FF`).

---

## 2. Brecha entre el Concepto (Corte 1) y la Plantilla Actual (Corte 2)

Actualmente existe una **divergencia importante** entre el PDF de Corte 1 y lo que está construido/planteado para Corte 2:

| Aspecto | Concepto Original (PDF Corte 1) | Estado / Planteamiento Actual (Corte 2) |
| :--- | :--- | :--- |
| **Control del jugador** | Operador remoto sin avatar; no controla personajes, solo puertas con clic izquierdo y cámara cenital. | Existe un `Personaje` jugable (`WASD`) que camina por el mapa y va a **recoger** civiles. |
| **Comportamiento del civil** | Navegan autónomamente por rutas hacia la salida verde (`NavigationServer3D`). | Patrullan y persiguen al `Personaje` desde `6 m` hasta `9 m`, bloqueando el paso. |
| **Puertas** | Se alternan a distancia con clic izquierdo y un retardo táctico de `1.5 s`. | Se abren con `E` (espera `1.5 s` + `0.5 s` tween) o con clic izquierdo instantáneo vía `apuntar.gd`. |
| **Mapa** | Celdas/pasillos amplios pensados para flujo de multitudes desde vista cenital. | Mapa dummy `16 × 16 m` con pasillos de `2.4 m` donde 2 personajes ya se estorban. |

> **Decisión clave antes de programar el core:** Definir si el juego final seguirá el modelo **Híbrido Rescate (con avatar que recoge y escolta civiles)** o el modelo **Operador Cenital (sin avatar, puro RTS de puertas)**, o una combinación (ej. operador que también se mueve por la sala/mapa). El plan siguiente resuelve primero los problemas físicos/espaciales que afectan a **ambos** enfoques y prepara el terreno para el mapa original.

---

## 3. Solución a los Problemas Reportados

### Problema 1: Espacio insuficiente y obstrucción entre personajes
* **Causa raíz actual:**
  1. En `main.tscn`, los pasillos centrales miden apenas `2.4 m` de ancho (`x = -1.2` a `x = 1.2`, menos `0.4 m` de grosor de muro = `2.0 m` libres reales), y cada cápsula tiene `0.70 m` de diámetro (`radius = 0.35`). Con 2 o 3 personajes en fila o cruzándose, el paso queda prácticamente sellado.
  2. El `civil` persigue hasta chocar cuerpo a cuerpo con el jugador (distancia `0 m`) y sigue empujando en `PERSEGUIR`.
  3. El `radio_ver = 6.0 m` es demasiado grande para un mapa de `16 × 16 m`, por lo que te detecta casi desde cualquier habitación.
* **Solución recomendada:**
  * **Separación física vs. congestión controlada:** Configurar capas de colisión (`Collision Layers / Masks`) para que `Personaje` y `Civil` colisionen con el entorno (paredes/puertas), pero **no se bloqueen rígidamente entre sí** (o usar un `Area3D` suave de separación / reducción de velocidad al amontonarse, replicando la mecánica de congestión del GDD sin trabar la física).
  * **Distancia de seguimiento y recogida en `civil.gd`:**
    * Cambiar el flujo a: `PATRULLA` / `ESPERA` → solo se activa al **recogerlo** (interacción cercana `< 1.8 m` o entrar en su `Area3D` de rescate) o reducir `radio_ver` drásticamente (`~2.0 m`) si es por proximidad.
    * Añadir una **distancia mínima de parada** (`distancia_parada = 1.5 m`) para que el civil te siga detrás sin pegarse ni empujarte.
    * Integrar `NavigationAgent3D` para que rodee esquinas y puertas en lugar de atascarse en los muros.

### Problema 2: Las puertas se demoran en abrir
* **Causa raíz actual:** En `accion_puerta.gd`, al pulsar `E`, el estado `ACTIVA` espera `1.5 s` sin feedback antes de siquiera empezar el `Tween` de `0.5 s` (`puerta.gd`), más `1.0 s` de recarga (`3.0 s` en total). Además, el raycast de `apuntar.gd` las abre al instante, creando inconsistencia.
* **Solución recomendada:**
  * Si el enfoque es acción fluida (personaje recogiendo civiles): bajar `duracion` de activación a `0.0 - 0.2 s` y ajustar el `Tween` de apertura a `0.25 - 0.35 s` (y usar `Area3D` en la puerta para detectar al jugador en vez de buscar `"Personaje"` por nombre).
  * Si se conserva el retardo de `1.5 s` del GDD como mecánica táctica: agregar **feedback visual inmediato** (cambio de color / barra de progreso / parpadeo desde el segundo `0.0`) para que el jugador sepa que la orden fue recibida, y unificar el método de activación (eliminar la doble vía contradictoria entre `apuntar.gd` y `accion_puerta.gd`).

### Problema 3: Dimensiones del mapa dummy antes de construir los planos originales
* **Regla de escala recomendada para Godot 3D (con modelos Kenney escalados a `2.6`):**
  * Diámetro de personaje: `~0.7 m` (altura `~1.75 m`).
  * **Pasillos secundarios:** mínimo `3.0 m - 3.5 m` libres (caben 3–4 personajes en paralelo sin atasco).
  * **Pasillos principales / rutas de evacuación:** `4.5 m - 6.0 m` libres.
  * **Puertas:** ancho de abertura de `2.5 m - 3.0 m` (actualmente `2.0 m`) para permitir paso fluido de grupos.
  * **Salas / oficinas:** mínimo `6 × 6 m` a `8 × 8 m`.
  * **Cámara:** ajustar `distancia` y `limite_min / limite_max` proporcionalmente al tamaño total del plano real (o calcular límites dinámicos según el mapa).

---

## 4. Plan de Acción por Fases

### Fase 1: Limpieza, Organización y Escenas Base (Sin romper lo actual)
1. Reorganizar `Panic Route/` en subcarpetas limpias:
   * `escenas/` (`niveles/`, `entidades/`, `objetos/`, `ui/`)
   * `scripts/` (o junto a cada entidad)
   * `assets/` (`modelos/`, `texturas/`, `audio/`)
2. Eliminar `AccionPuerta.gd` (vacío) y los muros `CSGBox3D` duplicados en `main.tscn`.
3. Convertir `Personaje` y `Civil` en escenas independientes (`personaje.tscn` y `civil.tscn`), usando grupos (`"jugador"`, `"civiles"`, `"puertas"` sin duplicar el grupo en nodos hijos).

### Fase 2: Corrección de Movimiento, Espacio, Civiles y Puertas (Sobre el dummy reescalado)
1. Ampliar las proporciones del mapa dummy (pasillos ≥ `3.5 m`, puertas ≥ `2.5 m`) y probar con 5–10 civiles simultáneos.
2. Ajustar colisiones entre personajes (`collision_layer` / `collision_mask`) para evitar bloqueos físicos, implementando la regla de congestión (reducción de velocidad al agruparse) por código/área si se desea conservar esa mecánica.
3. Refactorizar `civil.gd`: añadir `NavigationAgent3D`, estado de espera/recogida (no perseguir desde lejos sin ser recogido) y distancia de parada (`1.5 m`).
4. Ajustar respuesta de `puerta.tscn` (velocidad de apertura ágil + detección por `Area3D` o clic consistente).

### Fase 3: Construcción del Mapa Original (Desde los planos)
1. Definir la grilla/escala exacta usando las métricas validadas en la Fase 2.
2. Construir la geometría definitiva del nivel (con `NavigationRegion3D` horneada para las rutas de evacuación).
3. Ubicar puntos de aparición de civiles, zonas seguras (`#06D6A0`) y puertas cortafuegos.

### Fase 4: Core Loop y Condiciones de Juego
1. **Sistema de Fuego / Amenaza:** Propagación periódica por celdas/zonas con partículas/luz naranja (`#FF7B00`) que bloquee rutas y dañe civiles.
2. **Zona Segura y Conteo:** Registro de civiles evacuados vs. bajas.
3. **HUD y Estados de Partida:** Contador de evacuados/tiempo, alerta de congestión/fuego, pausa táctica (`ESPACIO`), pantalla de **Victoria** (100% o meta cumplida) y **Derrota** (>20% bajas).
4. **Pulido:** Iluminación clínica vs. cálida del fuego, feedback visual/sonoro en puertas y menú principal.
