# Turco

Aplicación Flutter para Android que gestiona los **turnos de una peluquería mixta**: clientes, servicios, estilistas y agenda diaria. Proyecto del Primer Examen Parcial de *Programación para Dispositivos Móviles* (Ingeniería Informática, 3.er año).

- **Autor:** Marlom Sánchez
- **Application id:** `com.marlomsanchez.turco`
- **Nombre visible:** Turco
- **Versión de Flutter usada:** _(completar con la salida de `flutter --version`)_
- **Datos:** todo en memoria, cargado desde datos de prueba. Sin servidor ni base de datos.

## Cómo inicializar y ejecutar

```bash
git clone <URL-DEL-REPOSITORIO>
cd turco
flutter pub get
flutter run
```

Requisitos: Flutter SDK instalado, Android Studio con el SDK de Android y un emulador o un teléfono con depuración USB. Comprueba el entorno con `flutter doctor`.

## Cómo generar el APK release

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`. El APK final se publica en la sección **Releases** del repositorio.

## Arquitectura

MVVM con `ChangeNotifier` y `ListenableBuilder`, sin paquetes externos de estado. La navegación usa solo `go_router` con `StatefulShellRoute.indexedStack`.

## Estructura de carpetas

```
lib/
├── main.dart            # punto de entrada
├── app.dart             # MaterialApp.router y tema
├── router/              # rutas de go_router
├── theme/               # tema claro y oscuro (Material 3)
├── core/                # constantes y utilidades
├── models/              # Servicio, Estilista, Cliente, Turno
├── data/                # datos de prueba
├── viewmodels/          # estado y reglas de negocio
├── views/               # pantallas
└── widgets/             # componentes reutilizables
assets/
├── images/              # logo, categorías y avatares
└── fonts/               # Poppins
capturas/                # capturas reales de la app
entrega/                 # APK release
```

## Capturas

Las capturas reales están en la carpeta `capturas/`.
