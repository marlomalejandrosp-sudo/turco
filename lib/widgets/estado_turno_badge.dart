import 'package:flutter/material.dart';

import '../core/estado_colores.dart';
import '../models/enums.dart';

/// Etiqueta con el estado de un turno ("Programado", "Completado"...).
class EstadoTurnoBadge extends StatelessWidget {
  const EstadoTurnoBadge({super.key, required this.estado});

  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: estado.fondo(colores),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          estado.etiqueta,
          style: tema.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: estado.texto(colores),
          ),
        ),
      ),
    );
  }
}
