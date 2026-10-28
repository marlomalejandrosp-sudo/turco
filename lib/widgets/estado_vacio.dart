import 'package:flutter/material.dart';

/// Mensaje con ilustración para listas vacías, filtros sin resultados o
/// elementos que no existen.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;

  /// Botón opcional bajo el mensaje (por ejemplo, "Volver a la agenda").
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ilustración: círculo de 120 con el icono de 56
            DecoratedBox(
              decoration: BoxDecoration(
                color: colores.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Icon(icono, size: 56, color: colores.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                mensaje,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ),
            if (accion != null) ...[
              const SizedBox(height: 20),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
