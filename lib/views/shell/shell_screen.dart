import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Contenedor con la barra de navegación inferior (4 destinos).
/// Cada destino es una rama de StatefulShellRoute.indexedStack, por eso
/// conserva su estado y su posición de scroll al cambiar de pestaña.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    // Atrás del sistema: desde Clientes, Servicios o Estilistas vuelve a
    // la Agenda; solo desde la Agenda se sale de la app.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (salio, _) {
        if (!salio) shell.goBranch(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Agenda',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.content_cut),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.contacts_outlined),
              selectedIcon: Icon(Icons.contacts),
              label: 'Estilistas',
            ),
          ],
        ),
      ),
    );
  }
}
