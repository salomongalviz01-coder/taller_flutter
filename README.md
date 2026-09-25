# Taller 1 – Flutter: StatefulWidget y setState()

**Estudiante:** Salomon Galviz
**Código:** 230232004
**Asignatura:** Electiva Profesional 1

## Descripción

Pantalla básica en Flutter (`HomePage`) construida con `StatefulWidget`. Un `ElevatedButton`
alterna el título de la `AppBar` entre "Hola, Flutter" y "¡Título cambiado!" usando `setState()`
y muestra un `SnackBar` con el mensaje "Título actualizado". Incluye imágenes con
`Image.network()` e `Image.asset()` en un `Row`, y los widgets adicionales `Container`,
`ListView` y `ElevatedButton.icon`.

El trabajo se realizó con Git Flow simplificado: rama `feature/taller1` (creada desde `dev`),
Pull Request a `dev` y posterior integración de `dev` a `main`.

## Pasos para ejecutar

```bash
git clone https://github.com/salomongalviz01-coder/taller_flutter.git
cd NOMBRE_DEL_REPO
git checkout feature/taller1
flutter pub get
flutter run
```

## Capturas

**Estado inicial**

![Estado inicial](capturas/01_inicial.png)

**Título cambiado**

![Título cambiado](capturas/02_titulo_cambiado.png)

**SnackBar**

![SnackBar](capturas/03_snackbar.png)

**Container y ListView**

![Container y ListView](capturas/04_container_listview.png)

**ElevatedButton.icon**

![Botón con icono](capturas/05_boton_icono.png)

## Ramas

- `main`: rama estable
- `dev`: rama de desarrollo
- `feature/taller1`: cambios de este taller
