import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Vuelve a la pantalla anterior; si no hay (por ejemplo, se abrió la ruta
/// directamente), va a la Agenda. Puede devolver un [resultado].
void volverOAgenda(BuildContext context, [Object? resultado]) {
  if (context.canPop()) {
    context.pop(resultado);
  } else {
    context.go('/agenda');
  }
}
