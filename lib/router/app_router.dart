import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_dependencies.dart';
import '../models/flujo_turno.dart';
import '../views/agenda/agenda_screen.dart';
import '../views/clientes/clientes_screen.dart';
import '../views/detalle/detalle_screen.dart';
import '../views/estilistas/estilistas_screen.dart';
import '../views/servicios/servicios_screen.dart';
import '../views/shell/shell_screen.dart';
import '../views/turno_form/turno_form_screen.dart';

/// Navegador raíz: las pantallas Detalle y Formulario se abren en él, por
/// encima de la barra de navegación inferior (parentNavigatorKey).
final GlobalKey<NavigatorState> _navegadorRaiz =
    GlobalKey<NavigatorState>(debugLabel: 'raiz');

GoRouter crearRouter(AppDependencies deps) {
  return GoRouter(
    navigatorKey: _navegadorRaiz,
    initialLocation: '/agenda',
    routes: [
      // Las cuatro pestañas, cada una con su propio estado
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) => AgendaScreen(
                deps: deps,
                // Parámetro de consulta: /agenda?estilista=3
                estilistaId: state.uri.queryParameters['estilista'],
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/clientes',
              builder: (context, state) => ClientesScreen(deps: deps),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) => ServiciosScreen(deps: deps),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/estilistas',
              builder: (context, state) => EstilistasScreen(deps: deps),
            ),
          ]),
        ],
      ),

      // Crear turno (recibe datos iniciales con extra).
      // Debe ir antes de /turno/:id para que "nuevo" no se lea como id.
      GoRoute(
        path: '/turno/nuevo',
        parentNavigatorKey: _navegadorRaiz,
        builder: (context, state) {
          final extra = state.extra;
          return TurnoFormScreen(
            deps: deps,
            datos: extra is DatosInicialesTurno ? extra : null,
          );
        },
      ),

      // Detalle de turno (parámetro de ruta) y, dentro, su edición.
      GoRoute(
        path: '/turno/:id',
        parentNavigatorKey: _navegadorRaiz,
        builder: (context, state) => DetalleScreen(
          deps: deps,
          turnoId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'editar',
            parentNavigatorKey: _navegadorRaiz,
            builder: (context, state) => TurnoFormScreen(
              deps: deps,
              turnoId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
}
