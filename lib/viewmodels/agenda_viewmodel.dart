import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/reglas_salon.dart';
import '../models/resumen_dia.dart';
import '../models/turno.dart';
import 'salon_viewmodel.dart';

/// Estado de la pantalla Agenda: fecha seleccionada y filtros.
/// Vive mientras la app esté abierta, así la pestaña conserva su estado.
class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel(this.salon)
      : _fecha = ReglasSalon.soloFecha(salon.ahora) {
    salon.addListener(notifyListeners);
  }

  final SalonViewModel salon;

  DateTime _fecha;
  String? _estilistaId;
  EstadoTurno? _estado;

  @override
  void dispose() {
    salon.removeListener(notifyListeners);
    super.dispose();
  }

  DateTime get fecha => _fecha;
  String? get estilistaId => _estilistaId;
  EstadoTurno? get estado => _estado;

  bool get diaCerrado => !ReglasSalon.estaAbierto(_fecha);

  bool get hayFiltros => _estilistaId != null || _estado != null;

  bool esHoy(DateTime d) => ReglasSalon.mismoDia(d, salon.ahora);

  bool esSeleccionado(DateTime d) => ReglasSalon.mismoDia(d, _fecha);

  /// Los siete días (lunes a domingo) de la semana de la fecha elegida.
  List<DateTime> get diasDeLaSemana {
    final lunes = DateTime(_fecha.year, _fecha.month, _fecha.day - (_fecha.weekday - 1));
    return List.generate(
      7,
      (i) => DateTime(lunes.year, lunes.month, lunes.day + i),
    );
  }

  /// Resumen del día completo (no depende de los filtros).
  ResumenDia get resumen => salon.resumenDelDia(_fecha);

  /// Turnos del día con los filtros aplicados, ordenados por hora.
  List<Turno> get turnos {
    return salon.turnosDelDia(_fecha).where((t) {
      if (_estilistaId != null && t.estilistaId != _estilistaId) return false;
      if (_estado != null && t.estado != _estado) return false;
      return true;
    }).toList();
  }

  String nombreCliente(Turno t) => salon.clientePorId(t.clienteId)?.nombre ?? '—';

  String nombreEstilista(Turno t) =>
      salon.estilistaPorId(t.estilistaId)?.primerNombre ?? '—';

  // ---- Acciones ----

  void irAFecha(DateTime fecha) {
    _fecha = ReglasSalon.soloFecha(fecha);
    notifyListeners();
  }

  void semanaAnterior() =>
      irAFecha(DateTime(_fecha.year, _fecha.month, _fecha.day - 7));

  void semanaSiguiente() =>
      irAFecha(DateTime(_fecha.year, _fecha.month, _fecha.day + 7));

  /// `null` significa "Todos". Un identificador desconocido se ignora.
  void seleccionarEstilista(String? id) {
    if (id != null && salon.estilistaPorId(id) == null) return;
    if (id == _estilistaId) return;
    _estilistaId = id;
    notifyListeners();
  }

  void seleccionarEstado(EstadoTurno? estado) {
    if (estado == _estado) return;
    _estado = estado;
    notifyListeners();
  }

  void limpiarFiltros() {
    _estilistaId = null;
    _estado = null;
    notifyListeners();
  }
}
