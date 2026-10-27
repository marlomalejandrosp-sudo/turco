/// Por qué una franja horaria no se puede elegir.
enum MotivoNoDisponible {
  ocupadaEstilista,
  ocupadaCliente,
  pasada,
  fueraDeHorario,
}

/// Una franja de 30 minutos de la cuadrícula del formulario.
class Franja {
  const Franja({required this.inicio, this.motivo});

  final DateTime inicio;

  /// `null` significa que la franja está libre.
  final MotivoNoDisponible? motivo;

  bool get disponible => motivo == null;
}
