import 'package:flutter/material.dart';

import '../core/estado_colores.dart';
import '../core/formato.dart';
import '../models/turno.dart';
import 'estado_turno_badge.dart';

/// Tarjeta de un turno en la lista de la Agenda.
///
/// Muestra: barra con el color del estado, hora de inicio y fin, cliente,
/// servicios, estilista y estado.
class TarjetaTurno extends StatelessWidget {
  const TarjetaTurno({
    super.key,
    required this.turno,
    required this.nombreCliente,
    required this.nombreEstilista,
    this.onTap,
    this.onLongPress,
  });

  final Turno turno;
  final String nombreCliente;
  final String nombreEstilista;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final textos = tema.textTheme;

    final estiloPrincipal = textos.titleMedium?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
    final estiloSecundario = textos.bodyMedium?.copyWith(fontSize: 12);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra con el color del estado
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: turno.estado.barra(colores),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const SizedBox(width: 4),
                ),
                const SizedBox(width: 10),

                // Hora de inicio y de fin
                SizedBox(
                  width: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Formato.hora(turno.inicio), style: estiloPrincipal),
                      const SizedBox(height: 2),
                      Text(Formato.hora(turno.fin), style: estiloSecundario),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Cliente, servicios, estilista y estado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreCliente,
                        style: estiloPrincipal,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        turno.serviciosTexto,
                        style: estiloSecundario,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 13,
                            color: colores.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              nombreEstilista,
                              style: estiloSecundario?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          EstadoTurnoBadge(estado: turno.estado),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
