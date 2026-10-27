import 'enums.dart';
import 'servicio.dart';

/// Un turno: un cliente, un estilista y uno o varios servicios.
///
/// La hora de fin, la duración y el total NO se guardan: se calculan.
class Turno {
  Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required List<Servicio> servicios,
    required this.inicio,
    this.notas,
    this.estado = EstadoTurno.programado,
    required this.creadoEn,
    required this.modificadoEn,
  }) : servicios = List.unmodifiable(servicios);

  final String id;
  final String clienteId;
  final String estilistaId;
  final List<Servicio> servicios;
  final DateTime inicio;
  final String? notas;
  final EstadoTurno estado;
  final DateTime creadoEn;
  final DateTime modificadoEn;

  // ---- Valores calculados ----

  /// Suma de las duraciones de sus servicios.
  int get duracionMin =>
      servicios.fold<int>(0, (suma, s) => suma + s.duracionMin);

  /// Hora de fin = inicio + duración.
  DateTime get fin => inicio.add(Duration(minutes: duracionMin));

  /// Precio total = suma de los precios de sus servicios.
  int get total => servicios.fold<int>(0, (suma, s) => suma + s.precio);

  /// Nombres de los servicios unidos con " + ".
  String get serviciosTexto => servicios.map((s) => s.nombre).join(' + ');

  // ---- Reglas de estado ----

  /// Solo los turnos programados se pueden editar, completar o cancelar.
  bool get esEditable => estado == EstadoTurno.programado;

  /// Los turnos cancelados no ocupan horario.
  bool get ocupaHorario => estado != EstadoTurno.cancelado;

  /// True si el intervalo [otroInicio, otroFin) se cruza con este turno.
  /// Un turno que termina a las 10:00 NO se solapa con otro que empieza
  /// a las 10:00 (intervalos abiertos en el extremo final).
  bool seSolapaCon(DateTime otroInicio, DateTime otroFin) =>
      inicio.isBefore(otroFin) && otroInicio.isBefore(fin);

  // ---- Copia con cambios ----

  static const Object _sinCambio = Object();

  /// Copia del turno con algunos campos cambiados. Para [notas] se puede
  /// pasar `null` explícito para borrarlas.
  Turno copyWith({
    String? clienteId,
    String? estilistaId,
    List<Servicio>? servicios,
    DateTime? inicio,
    Object? notas = _sinCambio,
    EstadoTurno? estado,
    DateTime? modificadoEn,
  }) {
    return Turno(
      id: id,
      clienteId: clienteId ?? this.clienteId,
      estilistaId: estilistaId ?? this.estilistaId,
      servicios: servicios ?? this.servicios,
      inicio: inicio ?? this.inicio,
      notas: identical(notas, _sinCambio) ? this.notas : notas as String?,
      estado: estado ?? this.estado,
      creadoEn: creadoEn,
      modificadoEn: modificadoEn ?? this.modificadoEn,
    );
  }

  @override
  bool operator ==(Object other) => other is Turno && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
