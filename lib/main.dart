import 'package:flutter/material.dart';

import 'app.dart';
import 'app_dependencies.dart';
import 'router/app_router.dart';

void main() {
  // Los ViewModels se crean una sola vez y viven toda la sesión.
  final deps = AppDependencies.crear();
  final router = crearRouter(deps);
  runApp(TurcoApp(deps: deps, router: router));
}
