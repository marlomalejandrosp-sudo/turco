import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../core/formato.dart';
import '../core/resultado.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/franja.dart';
import '../models/reglas_salon.dart';
import '../models/resumen_dia.dart';
import '../models/servicio.dart';
import '../models/turno.dart';

/// ViewModel compartido: guarda en memoria los servicios, estilistas,
/// clientes y turnos, y aplica TODAS las reglas de negocio.
///
/// Los ViewModels de cada pantalla le piden los datos y las operaciones.
/// Cada cambio llama a [notifyListeners], así todas las pantallas se
/// actualizan al instante.
class SalonViewModel extends ChangeNotifier {
  SalonViewModel({
    required List<Servicio> servicios,
    required List<Estilista> estilistas,
    required List<Cliente> clientes,
    required List<Turno> turnos,
    DateTime Function()? reloj,
  })  : _servicios = List.of(servicios),
        _estilistas = List.of(estilistas),
        _clientes = List.of(clientes),
        _turnos = List.of(turnos),
        _reloj = reloj ?? DateTime.now;

  final List<Servicio> _servicios;
  final List<Estilista> _estilistas;
  final List<Cliente> _clientes;
  final List<Turno> _turnos;
  final DateTime Function() _reloj;

  static const int notasMax = 500;

  /// El momento actual (se puede sustituir en pruebas).
  DateTime get ahora => _reloj();

  // ------------------------------------------------------------------
  // Consultas
  // ------------------------------------------------------------------

  List<Servicio> get servicios => UnmodifiableListView(_servicios);
  List<Estilista> get estilistas => UnmodifiableListView(_estilistas);
  List<Cliente> get clientes => UnmodifiableListView(_clientes);

  Servicio? servicioPorId(String id) {
    for (final s in _servicios) {
      if (s.id == id) return s;
    }
    return null;
  }

  Estilista? estilistaPorId(String id) {
    for (final e in _estilistas) {
      if (e.id == id) return e;
    }
    return null;
  }

  Cliente? clientePorId(String id) {
    for (final c in _clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Turno? turnoPorId(String id) {
    for (final t in _turnos) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Turnos de un día, ordenados por hora de inicio.
  List<Turno> turnosDelDia(DateTime fecha) {
    final lista =
        _turnos.where((t) => ReglasSalon.mismoDia(t.inicio, fecha)).toList();
    lista.sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  /// Historial de un cliente, del más reciente al más antiguo.
  List<Turno> turnosDeCliente(String clienteId) {
    final lista = _turnos.where((t) => t.clienteId == clienteId).toList();
    lista.sort((a, b) => b.inicio.compareTo(a.inicio));
    return lista;
  }

  int cantidadTurnosDeCliente(String clienteId) =>
      _turnos.where((t) => t.clienteId == clienteId).length;

  int programadosDeCliente(String clienteId) => _turnos
      .where((t) =>
          t.clienteId == clienteId && t.estado == EstadoTurno.programado)
      .length;

  /// Turnos programados que tiene un estilista en el día de hoy.
  int programadosHoy(String estilistaId) {
    final hoy = ahora;
    return _turnos
        .where((t) =>
            t.estilistaId == estilistaId &&
            t.estado == EstadoTurno.programado &&
            ReglasSalon.mismoDia(t.inicio, hoy))
        .length;
  }

  int get totalProgramadosHoy {
    final hoy = ahora;
    return _turnos
        .where((t) =>
            t.estado == EstadoTurno.programado &&
            ReglasSalon.mismoDia(t.inicio, hoy))
        .length;
  }

  /// Programados, completados e ingreso estimado de un día.
  ResumenDia resumenDelDia(DateTime fecha) {
    var programados = 0;
    var completados = 0;
    var ingreso = 0;
    for (final t in turnosDelDia(fecha)) {
      if (t.estado == EstadoTurno.programado) {
        programados++;
        ingreso += t.total;
      } else if (t.estado == EstadoTurno.completado) {
        completados++;
        ingreso += t.total;
      }
    }
    return ResumenDia(
      programados: programados,
      completados: completados,
      ingresoEstimado: ingreso,
    );
  }

  // ------------------------------------------------------------------
  // Disponibilidad (franjas)
  // ------------------------------------------------------------------

  /// Primer turno que ocupa horario y se cruza con [inicio]-[fin] para el
  /// estilista o el cliente indicados.
  Turno? _turnoEnChoque({
    required DateTime inicio,
    required DateTime fin,
    String? estilistaId,
    String? clienteId,
    String? excluirId,
  }) {
    for (final t in _turnos) {
      if (t.id == excluirId || !t.ocupaHorario) continue;
      final mismoEstilista = estilistaId != null && t.estilistaId == estilistaId;
      final mismoCliente = clienteId != null && t.clienteId == clienteId;
      if (!mismoEstilista && !mismoCliente) continue;
      if (t.seSolapaCon(inicio, fin)) return t;
    }
    return null;
  }

  /// Las franjas de 30 minutos de [fecha], cada una con su motivo si no
  /// está disponible. Se recalcula al cambiar servicios, estilista,
  /// cliente o fecha.
  ///
  /// [excluirTurnoId] y [inicioOriginal] se usan al editar: el propio
  /// turno no cuenta como solape consigo mismo y su horario original no
  /// se marca como pasado.
  List<Franja> franjasDisponibles({
    required DateTime fecha,
    required int duracionMin,
    String? estilistaId,
    String? clienteId,
    String? excluirTurnoId,
    DateTime? inicioOriginal,
  }) {
    final momento = ahora;
    final duracion =
        duracionMin <= 0 ? ReglasSalon.franjaMinutos : duracionMin;

    return ReglasSalon.franjasDelDia(fecha).map((inicio) {
      final fin = inicio.add(Duration(minutes: duracion));
      final esOriginal = inicioOriginal != null && inicio == inicioOriginal;

      MotivoNoDisponible? motivo;
      if (ReglasSalon.esPasado(inicio, momento) && !esOriginal) {
        motivo = MotivoNoDisponible.pasada;
      } else if (!ReglasSalon.terminaAntesDelCierre(inicio, duracion)) {
        motivo = MotivoNoDisponible.fueraDeHorario;
      } else if (estilistaId != null &&
          _turnoEnChoque(
                inicio: inicio,
                fin: fin,
                estilistaId: estilistaId,
                excluirId: excluirTurnoId,
              ) !=
              null) {
        motivo = MotivoNoDisponible.ocupadaEstilista;
      } else if (clienteId != null &&
          _turnoEnChoque(
                inicio: inicio,
                fin: fin,
                clienteId: clienteId,
                excluirId: excluirTurnoId,
              ) !=
              null) {
        motivo = MotivoNoDisponible.ocupadaCliente;
      }
      return Franja(inicio: inicio, motivo: motivo);
    }).toList();
  }

  // ------------------------------------------------------------------
  // Turnos: crear, editar, completar, cancelar
  // ------------------------------------------------------------------

  String? _limpiarNotas(String? notas) {
    final t = notas?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  /// Devuelve el mensaje del primer incumplimiento, o null si el turno
  /// es válido. Es la defensa final: aunque la interfaz falle, no se
  /// puede guardar un turno que rompa las reglas.
  String? _errorDeTurno({
    required String clienteId,
    required String estilistaId,
    required List<Servicio> servicios,
    required DateTime inicio,
    String? notas,
    String? excluirId,
    bool validarPasado = true,
  }) {
    final cliente = clientePorId(clienteId);
    if (cliente == null) return 'El cliente seleccionado no existe.';
    final estilista = estilistaPorId(estilistaId);
    if (estilista == null) return 'El estilista seleccionado no existe.';
    if (servicios.isEmpty) return 'Elige al menos un servicio';
    if (!estilista.realizaTodos(servicios)) {
      return '${estilista.nombre} no realiza todos los servicios elegidos.';
    }

    final duracion = servicios.fold<int>(0, (suma, s) => suma + s.duracionMin);
    final errorHorario = ReglasSalon.errorDeHorario(
      inicio,
      duracion,
      ahora,
      permitirPasado: !validarPasado,
    );
    if (errorHorario != null) return errorHorario;

    final fin = inicio.add(Duration(minutes: duracion));
    if (_turnoEnChoque(
          inicio: inicio,
          fin: fin,
          estilistaId: estilistaId,
          excluirId: excluirId,
        ) !=
        null) {
      return '${estilista.nombre} ya tiene un turno en ese horario.';
    }
    if (_turnoEnChoque(
          inicio: inicio,
          fin: fin,
          clienteId: clienteId,
          excluirId: excluirId,
        ) !=
        null) {
      return '${cliente.nombre} ya tiene un turno en ese horario.';
    }
    if (notas != null && notas.trim().length > notasMax) {
      return 'Las notas no pueden pasar de $notasMax caracteres.';
    }
    return null;
  }

  String _nuevoId(Iterable<String> ids) {
    var maximo = 0;
    for (final id in ids) {
      final n = int.tryParse(id) ?? 0;
      if (n > maximo) maximo = n;
    }
    return '${maximo + 1}';
  }

  Resultado<Turno> crearTurno({
    required String clienteId,
    required String estilistaId,
    required List<Servicio> servicios,
    required DateTime inicio,
    String? notas,
  }) {
    final error = _errorDeTurno(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: servicios,
      inicio: inicio,
      notas: notas,
    );
    if (error != null) return Resultado<Turno>.fallo(error);

    final momento = ahora;
    final turno = Turno(
      id: _nuevoId(_turnos.map((t) => t.id)),
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: servicios,
      inicio: inicio,
      notas: _limpiarNotas(notas),
      estado: EstadoTurno.programado,
      creadoEn: momento,
      modificadoEn: momento,
    );
    _turnos.add(turno);
    notifyListeners();
    return Resultado<Turno>.ok(turno);
  }

  Resultado<Turno> editarTurno({
    required String id,
    required String clienteId,
    required String estilistaId,
    required List<Servicio> servicios,
    required DateTime inicio,
    String? notas,
  }) {
    final original = turnoPorId(id);
    if (original == null) {
      return Resultado<Turno>.fallo('El turno no existe o ya no está disponible.');
    }
    if (!original.esEditable) {
      return Resultado<Turno>.fallo(
          'Solo se pueden editar los turnos programados.');
    }

    final error = _errorDeTurno(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: servicios,
      inicio: inicio,
      notas: notas,
      excluirId: id,
      // Solo se exige "no pasado" si se está reprogramando.
      validarPasado: inicio != original.inicio,
    );
    if (error != null) return Resultado<Turno>.fallo(error);

    final editado = original.copyWith(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicios: servicios,
      inicio: inicio,
      notas: _limpiarNotas(notas),
      modificadoEn: ahora,
    );
    _reemplazarTurno(editado);
    notifyListeners();
    return Resultado<Turno>.ok(editado);
  }

  Resultado<Turno> completarTurno(String id) =>
      _cambiarEstado(id, EstadoTurno.completado, 'completar');

  Resultado<Turno> cancelarTurno(String id) =>
      _cambiarEstado(id, EstadoTurno.cancelado, 'cancelar');

  Resultado<Turno> _cambiarEstado(
    String id,
    EstadoTurno nuevo,
    String verbo,
  ) {
    final turno = turnoPorId(id);
    if (turno == null) {
      return Resultado<Turno>.fallo('El turno no existe o ya no está disponible.');
    }
    if (!turno.esEditable) {
      return Resultado<Turno>.fallo(
          'Solo se pueden $verbo los turnos programados.');
    }
    final actualizado = turno.copyWith(estado: nuevo, modificadoEn: ahora);
    _reemplazarTurno(actualizado);
    notifyListeners();
    return Resultado<Turno>.ok(actualizado);
  }

  void _reemplazarTurno(Turno nuevo) {
    final i = _turnos.indexWhere((t) => t.id == nuevo.id);
    if (i >= 0) _turnos[i] = nuevo;
  }

  // ------------------------------------------------------------------
  // Clientes: registrar, editar, eliminar
  // ------------------------------------------------------------------

  /// True si otro cliente (distinto de [excluirId]) ya usa ese teléfono.
  bool telefonoEnUso(String telefono, {String? excluirId}) {
    return _clientes.any((c) => c.telefono == telefono && c.id != excluirId);
  }

  String? _errorDeCliente({
    required String nombre,
    required String telefono,
    String? correo,
    String? excluirId,
  }) {
    if (!Cliente.nombreValido(nombre)) return 'Escribe entre 3 y 60 caracteres';
    final tel = telefono.trim();
    if (!Cliente.telefonoValido(tel)) return 'Debe tener exactamente 8 dígitos';
    if (telefonoEnUso(tel, excluirId: excluirId)) {
      return 'Ya existe un cliente con este teléfono';
    }
    final c = correo?.trim() ?? '';
    if (c.isNotEmpty && !Cliente.correoValido(c)) {
      return 'Escribe un correo válido';
    }
    return null;
  }

  String? _correoOpcional(String? correo) {
    final c = correo?.trim();
    return (c == null || c.isEmpty) ? null : c;
  }

  Resultado<Cliente> registrarCliente({
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final error = _errorDeCliente(
      nombre: nombre,
      telefono: telefono,
      correo: correo,
    );
    if (error != null) return Resultado<Cliente>.fallo(error);

    final cliente = Cliente(
      id: _nuevoId(_clientes.map((c) => c.id)),
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      genero: genero,
      correo: _correoOpcional(correo),
      fechaRegistro: ahora,
    );
    _clientes.add(cliente);
    notifyListeners();
    return Resultado<Cliente>.ok(cliente);
  }

  Resultado<Cliente> editarCliente({
    required String id,
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) {
    final original = clientePorId(id);
    if (original == null) {
      return Resultado<Cliente>.fallo('El cliente no existe.');
    }
    final error = _errorDeCliente(
      nombre: nombre,
      telefono: telefono,
      correo: correo,
      excluirId: id,
    );
    if (error != null) return Resultado<Cliente>.fallo(error);

    final editado = Cliente(
      id: original.id,
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      genero: genero,
      correo: _correoOpcional(correo),
      fechaRegistro: original.fechaRegistro,
    );
    final i = _clientes.indexWhere((c) => c.id == id);
    _clientes[i] = editado;
    notifyListeners();
    return Resultado<Cliente>.ok(editado);
  }

  /// No se puede eliminar un cliente con turnos programados. Si no los
  /// tiene, se elimina junto con su historial (completados y cancelados).
  Resultado<Cliente> eliminarCliente(String id) {
    final cliente = clientePorId(id);
    if (cliente == null) {
      return Resultado<Cliente>.fallo('El cliente no existe.');
    }
    final programados = programadosDeCliente(id);
    if (programados > 0) {
      final texto = Formato.plural(
        programados,
        'turno programado',
        'turnos programados',
      );
      return Resultado<Cliente>.fallo(
          'No se puede eliminar: ${cliente.nombre} tiene $texto.');
    }
    _turnos.removeWhere((t) => t.clienteId == id);
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
    return Resultado<Cliente>.ok(cliente);
  }
}
