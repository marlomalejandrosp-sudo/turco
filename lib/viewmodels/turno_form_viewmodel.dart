import 'package:flutter/foundation.dart';

import '../core/resultado.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/flujo_turno.dart';
import '../models/franja.dart';
import '../models/reglas_salon.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import 'salon_viewmodel.dart';

/// Estado y reglas del formulario de turno (crear y editar).
///
/// La pantalla solo muestra lo que este ViewModel calcula: servicios
/// visibles, estilistas válidos, franjas disponibles, resumen y errores.
class TurnoFormViewModel extends ChangeNotifier {
  TurnoFormViewModel({
    required this.salon,
    this.turnoEditado,
    DatosInicialesTurno? datos,
  }) {
    final editado = turnoEditado;
    if (editado != null) {
      _cargarTurno(editado);
    } else {
      _cargarDatosIniciales(datos);
    }
    _inicial = _instantanea();
  }

  final SalonViewModel salon;

  /// El turno que se edita, o null si se está creando uno nuevo.
  final Turno? turnoEditado;

  Cliente? _cliente;
  final List<Servicio> _servicios = [];
  Estilista? _estilista;
  DateTime? _fecha;
  DateTime? _hora;
  String _notas = '';
  Publico? _publico;
  String? _aviso;
  String _inicial = '';

  // ------------------------------------------------------------------
  // Carga inicial
  // ------------------------------------------------------------------

  void _cargarTurno(Turno t) {
    _cliente = salon.clientePorId(t.clienteId);
    _servicios.addAll(t.servicios);
    _estilista = salon.estilistaPorId(t.estilistaId);
    _fecha = ReglasSalon.soloFecha(t.inicio);
    _hora = t.inicio;
    _notas = t.notas ?? '';
    _publico = _cliente?.genero.publicoPorDefecto;
  }

  void _cargarDatosIniciales(DatosInicialesTurno? datos) {
    final clienteId = datos?.clienteId;
    if (clienteId != null) {
      _cliente = salon.clientePorId(clienteId);
      _publico = _cliente?.genero.publicoPorDefecto;
    }
    final servicioId = datos?.servicioId;
    if (servicioId != null) {
      final s = salon.servicioPorId(servicioId);
      if (s != null) _servicios.add(s);
    }
    final fecha = datos?.fecha;
    if (fecha != null && fechaPermitida(fecha)) {
      _fecha = ReglasSalon.soloFecha(fecha);
    } else {
      _fecha = primeraFechaPermitida();
    }
  }

  /// Hoy, o el siguiente día en que el salón abre.
  DateTime primeraFechaPermitida() {
    var d = ReglasSalon.soloFecha(salon.ahora);
    while (!ReglasSalon.estaAbierto(d)) {
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return d;
  }

  // ------------------------------------------------------------------
  // Lectura del estado
  // ------------------------------------------------------------------

  bool get esEdicion => turnoEditado != null;

  Cliente? get cliente => _cliente;
  List<Servicio> get serviciosElegidos => List.unmodifiable(_servicios);
  Estilista? get estilista => _estilista;
  DateTime? get fecha => _fecha;
  DateTime? get hora => _hora;
  String get notas => _notas;
  Publico? get publico => _publico;

  bool estaSeleccionado(Servicio s) => _servicios.contains(s);

  /// Clientes entre los que se puede elegir.
  List<Cliente> get clientesDisponibles {
    final lista = List<Cliente>.of(salon.clientes);
    lista.sort((a, b) => a.nombre.compareTo(b.nombre));
    return lista;
  }

  /// Servicios visibles según el filtro de público, agrupados por categoría.
  Map<CategoriaServicio, List<Servicio>> get serviciosPorCategoria {
    final mapa = <CategoriaServicio, List<Servicio>>{};
    for (final categoria in CategoriaServicio.values) {
      final lista = salon.servicios
          .where((s) => s.categoria == categoria && s.sirveA(_publico))
          .toList();
      if (lista.isNotEmpty) mapa[categoria] = lista;
    }
    return mapa;
  }

  /// Solo los estilistas que realizan TODOS los servicios elegidos.
  /// Sin servicios elegidos no se ofrece ninguno.
  List<Estilista> get estilistasDisponibles {
    if (_servicios.isEmpty) return const [];
    return salon.estilistas.where((e) => e.realizaTodos(_servicios)).toList();
  }

  bool get estilistasHabilitados => _servicios.isNotEmpty;

  // ------------------------------------------------------------------
  // Resumen (siempre visible)
  // ------------------------------------------------------------------

  int get duracionTotal =>
      _servicios.fold<int>(0, (suma, s) => suma + s.duracionMin);

  int get precioTotal =>
      _servicios.fold<int>(0, (suma, s) => suma + s.precio);

  /// Hora de fin = hora de inicio + duración. Null si aún no hay hora.
  DateTime? get horaFin {
    final h = _hora;
    if (h == null) return null;
    return h.add(Duration(minutes: duracionTotal));
  }

  // ------------------------------------------------------------------
  // Fecha y franjas
  // ------------------------------------------------------------------

  /// No se permiten fechas pasadas ni domingos.
  bool fechaPermitida(DateTime f) {
    final hoy = ReglasSalon.soloFecha(salon.ahora);
    return !ReglasSalon.soloFecha(f).isBefore(hoy) && ReglasSalon.estaAbierto(f);
  }

  /// Franjas del día elegido, con su disponibilidad. Se recalculan al
  /// cambiar servicios, estilista, cliente o fecha.
  List<Franja> get franjas {
    final f = _fecha;
    if (f == null || !fechaPermitida(f)) return const [];
    return salon.franjasDisponibles(
      fecha: f,
      duracionMin: duracionTotal,
      estilistaId: _estilista?.id,
      clienteId: _cliente?.id,
      excluirTurnoId: turnoEditado?.id,
      inicioOriginal: turnoEditado?.inicio,
    );
  }

  bool get hayFranjasLibres => franjas.any((f) => f.disponible);

  // ------------------------------------------------------------------
  // Cambios que hace el usuario
  // ------------------------------------------------------------------

  void seleccionarCliente(Cliente? cliente) {
    _cliente = cliente;
    if (cliente != null) {
      // El filtro de público se ajusta al género, pero el usuario puede
      // cambiarlo después.
      _publico = cliente.genero.publicoPorDefecto;
    }
    _coherencia();
    notifyListeners();
  }

  void cambiarPublico(Publico? publico) {
    if (publico == _publico) return;
    _publico = publico;
    notifyListeners();
  }

  void alternarServicio(Servicio servicio) {
    if (_servicios.contains(servicio)) {
      _servicios.remove(servicio);
    } else {
      _servicios.add(servicio);
    }
    _coherencia();
    notifyListeners();
  }

  void seleccionarEstilista(Estilista? estilista) {
    _estilista = estilista;
    _coherencia();
    notifyListeners();
  }

  void elegirFecha(DateTime fecha) {
    if (!fechaPermitida(fecha)) return;
    _fecha = ReglasSalon.soloFecha(fecha);
    _coherencia();
    notifyListeners();
  }

  /// Solo se puede elegir una franja disponible.
  void elegirHora(DateTime hora) {
    final libre = franjas.any((f) => f.inicio == hora && f.disponible);
    if (!libre) return;
    _hora = hora;
    notifyListeners();
  }

  void cambiarNotas(String valor) {
    final antes = hayCambios;
    _notas = valor;
    // Solo se reconstruye la pantalla cuando cambia si hay cambios o no
    // (lo usa PopScope), no en cada letra.
    if (antes != hayCambios) notifyListeners();
  }

  /// Tras cualquier cambio, deja el formulario en un estado coherente:
  /// - Si el estilista elegido ya no realiza todos los servicios, se
  ///   limpia y se avisa.
  /// - Si la hora elegida ya no está libre, se limpia.
  void _coherencia() {
    final e = _estilista;
    if (e != null && (_servicios.isEmpty || !e.realizaTodos(_servicios))) {
      _estilista = null;
      _aviso = 'El estilista elegido ya no realiza todos los servicios. '
          'Elige otro.';
    }
    final h = _hora;
    if (h != null) {
      final sigueLibre = franjas.any((f) => f.inicio == h && f.disponible);
      if (!sigueLibre) _hora = null;
    }
  }

  /// Mensaje pendiente para mostrar una sola vez (por ejemplo, un
  /// SnackBar). Después de leerlo se borra.
  String? consumirAviso() {
    final a = _aviso;
    _aviso = null;
    return a;
  }

  bool get hayAviso => _aviso != null;

  // ------------------------------------------------------------------
  // Validaciones (mensajes del diseño)
  // ------------------------------------------------------------------

  String? validarCliente() => _cliente == null ? 'Selecciona un cliente' : null;

  String? validarServicios() =>
      _servicios.isEmpty ? 'Elige al menos un servicio' : null;

  String? validarEstilista() =>
      _estilista == null ? 'Selecciona un estilista' : null;

  String? validarFecha() {
    final f = _fecha;
    if (f == null) return 'Selecciona una fecha';
    if (!fechaPermitida(f)) return 'Elige una fecha válida (no domingos)';
    return null;
  }

  String? validarHora() =>
      _hora == null ? 'Elige una hora para el turno' : null;

  // ------------------------------------------------------------------
  // Cambios sin guardar (PopScope)
  // ------------------------------------------------------------------

  String _instantanea() {
    final ids = _servicios.map((s) => s.id).toList()..sort();
    return [
      _cliente?.id ?? '',
      ids.join(','),
      _estilista?.id ?? '',
      _fecha?.toIso8601String() ?? '',
      _hora?.toIso8601String() ?? '',
      _notas.trim(),
    ].join('|');
  }

  bool get hayCambios => _instantanea() != _inicial;

  // ------------------------------------------------------------------
  // Guardar
  // ------------------------------------------------------------------

  /// Crea o edita el turno. Las reglas se vuelven a comprobar en
  /// [SalonViewModel], así que aunque la pantalla falle no se puede
  /// guardar un turno inválido.
  Resultado<TurnoGuardado> guardar() {
    final cliente = _cliente;
    final estilista = _estilista;
    final hora = _hora;
    if (cliente == null || estilista == null || hora == null) {
      return Resultado<TurnoGuardado>.fallo(
          'Completa los campos obligatorios.');
    }

    final editado = turnoEditado;
    final Resultado<Turno> resultado;
    if (editado == null) {
      resultado = salon.crearTurno(
        clienteId: cliente.id,
        estilistaId: estilista.id,
        servicios: List.of(_servicios),
        inicio: hora,
        notas: _notas,
      );
    } else {
      resultado = salon.editarTurno(
        id: editado.id,
        clienteId: cliente.id,
        estilistaId: estilista.id,
        servicios: List.of(_servicios),
        inicio: hora,
        notas: _notas,
      );
    }

    if (!resultado.ok) {
      return Resultado<TurnoGuardado>.fallo(resultado.error!);
    }

    // Ya se guardó: salir de la pantalla no debe pedir confirmación.
    _inicial = _instantanea();

    final turno = resultado.valor!;
    return Resultado<TurnoGuardado>.ok(
      TurnoGuardado(
        turnoId: turno.id,
        fecha: ReglasSalon.soloFecha(turno.inicio),
        esNuevo: editado == null,
      ),
    );
  }
}
