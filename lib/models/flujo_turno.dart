/// Datos con los que se puede abrir el formulario de turno desde otras
/// pantallas (viajan con `extra` de go_router).
class DatosInicialesTurno {
  const DatosInicialesTurno({this.clienteId, this.servicioId, this.fecha});

  final String? clienteId;
  final String? servicioId;
  final DateTime? fecha;
}

/// Lo que el formulario devuelve con `context.pop(valor)` al guardar.
class TurnoGuardado {
  const TurnoGuardado({
    required this.turnoId,
    required this.fecha,
    required this.esNuevo,
  });

  final String turnoId;
  final DateTime fecha;
  final bool esNuevo;
}
