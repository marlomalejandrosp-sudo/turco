/// Resumen de un día de la agenda.
class ResumenDia {
  const ResumenDia({
    required this.programados,
    required this.completados,
    required this.ingresoEstimado,
  });

  final int programados;
  final int completados;

  /// Suma de los totales de los turnos programados y completados
  /// (los cancelados no cuentan).
  final int ingresoEstimado;
}
