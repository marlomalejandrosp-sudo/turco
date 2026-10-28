import 'package:flutter/material.dart';

import '../models/enums.dart';

/// Colores de cada estado de turno, tomados SIEMPRE del [ColorScheme]
/// (nunca colores fijos), así cambian solos en el modo oscuro.
extension ColoresDeEstado on EstadoTurno {
  /// Barra lateral de la tarjeta.
  Color barra(ColorScheme c) => switch (this) {
        EstadoTurno.programado => c.primary,
        EstadoTurno.completado => c.tertiary,
        EstadoTurno.cancelado => c.error,
      };

  /// Fondo de la etiqueta de estado.
  Color fondo(ColorScheme c) => switch (this) {
        EstadoTurno.programado => c.primaryContainer,
        EstadoTurno.completado => c.tertiaryContainer,
        EstadoTurno.cancelado => c.errorContainer,
      };

  /// Texto de la etiqueta de estado.
  Color texto(ColorScheme c) => switch (this) {
        EstadoTurno.programado => c.onPrimaryContainer,
        EstadoTurno.completado => c.onTertiaryContainer,
        EstadoTurno.cancelado => c.onErrorContainer,
      };
}
