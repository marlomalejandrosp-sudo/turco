/// Funciones para mostrar datos tal como los pide el diseño.
/// No usan `intl`, así no dependen de inicializar ningún idioma.
abstract final class Formato {
  static const _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const _diasCortos = [
    'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom',
  ];
  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
    'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String _dos(int n) => n.toString().padLeft(2, '0');

  /// "$ 45"
  static String precio(int valor) => '\$ $valor';

  /// "45 min", "60 min", "120 min" (así se ve en el catálogo).
  static String minutos(int min) => '$min min';

  /// "45 min", "1 h", "1 h 30 min" (así se ve en detalle y formulario).
  static String duracion(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  /// "52345678" -> "52 345 678"
  static String telefono(String t) {
    if (t.length != 8) return t;
    return '${t.substring(0, 2)} ${t.substring(2, 5)} ${t.substring(5)}';
  }

  /// "09:30"
  static String hora(DateTime d) => '${_dos(d.hour)}:${_dos(d.minute)}';

  /// "10:00 a 11:30"
  static String rangoHoras(DateTime inicio, DateTime fin) =>
      '${hora(inicio)} a ${hora(fin)}';

  /// "Miércoles"
  static String diaSemana(DateTime d) => _dias[d.weekday - 1];

  /// "Mié"
  static String diaSemanaCorto(DateTime d) => _diasCortos[d.weekday - 1];

  /// "Miércoles 21 de octubre de 2026"
  static String fechaLarga(DateTime d) =>
      '${diaSemana(d)} ${d.day} de ${_meses[d.month - 1]} de ${d.year}';

  /// "21/10/2026"
  static String fechaCorta(DateTime d) =>
      '${_dos(d.day)}/${_dos(d.month)}/${d.year}';

  /// "19/10"
  static String diaMes(DateTime d) => '${_dos(d.day)}/${_dos(d.month)}';

  /// "mié 21 de octubre" (para el aviso de turno guardado)
  static String fechaGuardado(DateTime d) =>
      '${_diasCortos[d.weekday - 1].toLowerCase()} ${d.day} de '
      '${_meses[d.month - 1]}';

  /// "Octubre 2026"
  static String mesAnio(DateTime d) {
    final mes = _meses[d.month - 1];
    return '${mes[0].toUpperCase()}${mes.substring(1)} ${d.year}';
  }

  /// "1 turno" / "3 turnos"
  static String plural(int n, String singular, String plural) =>
      '$n ${n == 1 ? singular : plural}';
}
