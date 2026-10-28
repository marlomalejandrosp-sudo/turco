/// Reglas de horario del salón. Son funciones puras: no dependen de
/// ningún widget.
abstract final class ReglasSalon {
  static const int horaApertura = 9;
  static const int horaCierre = 19;
  static const int franjaMinutos = 30;

  /// La fecha sin la hora (medianoche).
  static DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// El salón atiende de lunes a sábado.
  static bool estaAbierto(DateTime fecha) =>
      fecha.weekday != DateTime.sunday;

  static DateTime apertura(DateTime f) =>
      DateTime(f.year, f.month, f.day, horaApertura);

  static DateTime cierre(DateTime f) =>
      DateTime(f.year, f.month, f.day, horaCierre);

  /// Todas las franjas de inicio del día: 9:00, 9:30 ... 18:30.
  /// Un domingo no hay franjas.
  static List<DateTime> franjasDelDia(DateTime fecha) {
    if (!estaAbierto(fecha)) return const [];
    final lista = <DateTime>[];
    var actual = apertura(fecha);
    final fin = cierre(fecha);
    while (actual.isBefore(fin)) {
      lista.add(actual);
      actual = actual.add(const Duration(minutes: franjaMinutos));
    }
    return lista;
  }

  /// True si el turno, empezando en [inicio], termina a las 19:00 o antes.
  static bool terminaAntesDelCierre(DateTime inicio, int duracionMin) {
    final fin = inicio.add(Duration(minutes: duracionMin));
    return !fin.isAfter(cierre(inicio));
  }

  /// True si [inicio] cae exactamente en una franja de 30 minutos
  /// dentro del horario del salón.
  static bool esFranjaValida(DateTime inicio) {
    final enHorario =
        inicio.hour >= horaApertura && inicio.hour < horaCierre;
    return enHorario && inicio.minute % franjaMinutos == 0;
  }

  /// Un instante anterior a [ahora] ya pasó.
  static bool esPasado(DateTime inicio, DateTime ahora) =>
      inicio.isBefore(ahora);

  /// Devuelve el mensaje de error si el horario no cumple las reglas del
  /// salón, o `null` si es válido.
  ///
  /// Con [permitirPasado] en true no se comprueba que la hora ya pasó. Se
  /// usa al editar un turno sin cambiar su hora (por ejemplo, para
  /// corregir las notas de un turno que ya empezó hoy).
  static String? errorDeHorario(
    DateTime inicio,
    int duracionMin,
    DateTime ahora, {
    bool permitirPasado = false,
  }) {
    if (!estaAbierto(inicio)) {
      return 'El salón está cerrado los domingos.';
    }
    if (!permitirPasado && esPasado(inicio, ahora)) {
      return 'No se puede elegir una fecha y hora que ya pasaron.';
    }
    if (!esFranjaValida(inicio)) {
      return 'El turno debe empezar en una franja de 30 minutos '
          'entre las 9:00 y las 19:00.';
    }
    if (!terminaAntesDelCierre(inicio, duracionMin)) {
      return 'El turno debe terminar a las 19:00 como máximo.';
    }
    return null;
  }
}
