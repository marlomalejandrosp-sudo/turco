import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app_dependencies.dart';
import 'theme/app_theme.dart';

/// Raíz de la app: aplica el tema (claro, oscuro o del sistema) y el
/// router de go_router.
class TurcoApp extends StatelessWidget {
  const TurcoApp({super.key, required this.deps, required this.router});

  final AppDependencies deps;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    // Cuando cambia el modo de tema solo se reconstruye este árbol.
    return ListenableBuilder(
      listenable: deps.tema,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Turco',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: deps.tema.modo,
          routerConfig: router,
          // Español: selector de fecha, diálogos y textos del sistema.
          locale: const Locale('es'),
          supportedLocales: const [Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
