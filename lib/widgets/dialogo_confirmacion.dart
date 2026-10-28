import 'package:flutter/material.dart';

/// Muestra un diálogo de confirmación y devuelve true si el usuario
/// acepta.
///
/// Los diálogos y las hojas inferiores no son rutas de go_router, así que
/// se cierran con `Navigator.of(contexto).pop(valor)`. La navegación entre
/// pantallas sí usa solo go_router.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoConfirmar,
  String textoCancelar = 'Cancelar',
  bool destructivo = false,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (contextoDialogo) {
      final colores = Theme.of(contextoDialogo).colorScheme;
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contextoDialogo).pop(false),
            child: Text(textoCancelar),
          ),
          FilledButton(
            style: destructivo
                ? FilledButton.styleFrom(
                    backgroundColor: colores.error,
                    foregroundColor: colores.onError,
                  )
                : null,
            onPressed: () => Navigator.of(contextoDialogo).pop(true),
            child: Text(textoConfirmar),
          ),
        ],
      );
    },
  );
  return resultado ?? false;
}
