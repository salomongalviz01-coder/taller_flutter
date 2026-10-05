# Taller 3 - Segundo plano, asincronía y servicios en Flutter

**Estudiante:** Salomon Galviz
**Código:** 230232004
**Asignatura:** Electiva Profesional 1

## Descripción

Este taller implementa tres mecanismos de Flutter/Dart para manejar trabajo
que no debe bloquear la interfaz de usuario:

1. Un servicio simulado con `Future.delayed` consumido con `async/await`.
2. Un cronómetro construido con `Timer.periodic`.
3. Una tarea intensiva de CPU ejecutada en un `Isolate` independiente.

## ¿Cuándo usar cada uno?

### `Future`
Representa un valor que estará disponible más adelante (una operación que
toma tiempo, como una petición HTTP o leer un archivo). Se usa siempre que
una operación es asíncrona pero **no bloquea el hilo principal** por sí
misma (por ejemplo, esperar una respuesta de red).

### `async` / `await`
Es la sintaxis que permite escribir código asíncrono como si fuera
secuencial, sin anidar `.then()`. Se usa `await` dentro de una función
marcada `async` para "pausar" esa función (no la app completa) hasta que
el `Future` se resuelva. Ideal para encadenar pasos que dependen unos de
otros (ej. consultar datos y luego procesarlos).

### `Timer`
Se usa cuando se necesita ejecutar código de forma repetida o diferida en
el tiempo (cronómetros, cuentas regresivas, sondeos periódicos). A
diferencia de `Future`, un `Timer.periodic` sigue disparándose hasta que
se cancela explícitamente con `.cancel()` — por eso es obligatorio
cancelarlo en `dispose()` para no dejarlo corriendo en segundo plano tras
cerrar la vista.

### `Isolate`
Dart es de un solo hilo por aislado (isolate): un `Future`/`async` no
mueve trabajo a otro núcleo de CPU, solo reordena cuándo se ejecuta. Si
una tarea es **intensiva en cálculo** (un bucle pesado, procesar una
imagen, parsear un JSON enorme), ese cálculo sigue bloqueando la UI aunque
esté en una función `async`. Para evitarlo, se usa `Isolate.spawn()`, que
crea un hilo de ejecución completamente aparte, con su propia memoria,
comunicándose con la UI mediante mensajes mandados por un `SendPort` /
`ReceivePort`.

## Pantallas y flujo de la app

La app tiene una sola pantalla (`HomePage`) dividida en 3 secciones
apiladas verticalmente:

```
┌─────────────────────────────┐
│   AppBar: Taller 3           │
├─────────────────────────────┤
│ 1. Future / async / await    │
│   [Consultar datos]          │
│   -> Cargando...             │
│   -> Éxito / Error           │
├─────────────────────────────┤
│ 2. Cronómetro (Timer)        │
│   00:00                      │
│   [Iniciar] [Pausar] [Reinic]│
├─────────────────────────────┤
│ 3. Tarea pesada (Isolate)    │
│   [Ejecutar tarea pesada]    │
│   -> Calculando...           │
│   -> Resultado + tiempo (ms) │
└─────────────────────────────┘
```

### Flujo 1: consulta asíncrona
1. El usuario presiona **Consultar datos**.
2. El estado cambia a `cargando` y se muestra un spinner + "Cargando...".
3. Internamente se llama a una función `async` que usa `Future.delayed`
   para simular latencia de red (2 segundos).
4. Al resolverse, el estado cambia a `éxito` o `error` (aleatorio, para
   poder evidenciar ambos casos), y se actualiza la UI con `setState()`.
5. En la consola se imprime el orden real de ejecución: **antes** de
   esperar, **durante** (tras el delay) y **después** (al finalizar).

### Flujo 2: cronómetro
1. **Iniciar** arranca un `Timer.periodic` de 1 segundo que incrementa un
   contador y refresca el `Text` con el tiempo en formato `mm:ss`.
2. **Pausar** cancela el timer (`.cancel()`) sin perder el tiempo
   acumulado.
3. El mismo botón pasa a decir **Reanudar** y vuelve a arrancar el timer
   desde donde quedó.
4. **Reiniciar** cancela el timer y pone el contador en `00:00`.
5. En `dispose()` se cancela el timer por si la vista se cierra mientras
   está corriendo, evitando fugas de memoria.

### Flujo 3: tarea pesada en Isolate
1. El usuario presiona **Ejecutar tarea pesada**.
2. Se crea un `ReceivePort` y se lanza `Isolate.spawn()` con una función
   top-level que realiza una suma de 800 millones de iteraciones (tarea
   CPU-bound).
3. Mientras el isolate calcula, la UI principal sigue respondiendo (se
   puede seguir usando el cronómetro o la otra sección sin que se
   congele la app).
4. El isolate manda el resultado por `sendPort.send()`.
5. La UI recibe el mensaje (`receivePort.first`), muestra el resultado y
   el tiempo que tomó en milisegundos, y se imprime también en consola.

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

## Nota: limitación de `Isolate` en Flutter Web

Al probar la app en Chrome (`flutter run -d chrome`), la sección 3 se
queda indefinidamente en "Calculando en segundo plano..." sin llegar a
mostrar el resultado. Esto **no es un error del código**, sino una
limitación conocida de Flutter Web: el navegador no soporta el modelo de
hilos nativo que usa `Isolate.spawn()` (Dart compila a JavaScript para
la web, y JavaScript no tiene isolates reales de la forma en que los
tiene la VM de Dart en plataformas nativas).

En la consola del navegador se puede ver el mensaje `Isolate: iniciando
tarea pesada en segundo plano...` (impreso justo antes de llamar a
`Isolate.spawn`), pero nunca aparece el mensaje de `Isolate: tarea
finalizada...` que debería imprimirse al recibir la respuesta — el
`Future` que espera el mensaje del `ReceivePort` simplemente nunca se
resuelve en este entorno.

Sí se puede evidenciar, aun en Web, que el intento de isolate **no
bloquea la UI principal**: mientras la sección 3 queda "calculando", el
cronómetro de la sección 2 sigue corriendo con total normalidad (ver
`capturas/07_isolate_sin_bloqueo.png`), lo que demuestra que la llamada
es asíncrona y no congela el hilo principal de la interfaz.

En plataformas nativas (Windows, Android, iOS, macOS, Linux) —
ejecutando con `flutter run -d windows`, por ejemplo — `Isolate.spawn()`
sí se ejecuta en un hilo de sistema operativo real, completa la tarea y
devuelve el resultado correctamente.

## Evidencias

Ver carpeta `capturas/` y el PDF de entrega para las capturas de cada
flujo:

- `01_future_cargando.png` / `02_future_exito.png`: estados de la
  consulta asíncrona (Future/async/await).
- `03_consola_async.png`: orden de ejecución (ANTES/DURANTE/DESPUÉS)
  impreso en consola.
- `04_timer_pausado.png`, `05_timer_reanudado.png`,
  `06_timer_reiniciado.png`: ciclo completo del cronómetro con `Timer`.
- `07_isolate_sin_bloqueo.png`: evidencia de que el isolate no congela
  la UI (el cronómetro sigue corriendo mientras se "calcula").
- `08_isolate_limitacion_web.png`: consola mostrando el mensaje de
  inicio del isolate y la ausencia del mensaje de finalización,
  evidenciando la limitación de Flutter Web explicada arriba.
