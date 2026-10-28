import 'package:flutter/foundation.dart';

import '../core/resultado.dart';
import '../core/texto_utils.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/turno.dart';
import 'salon_viewmodel.dart';

/// Estado de la pantalla Clientes: búsqueda, filtro por género y
/// validaciones del formulario de alta y edición.
class ClientesViewModel extends ChangeNotifier {
  ClientesViewModel(this.salon) {
    salon.addListener(notifyListeners);
  }

  final SalonViewModel salon;

  String _busqueda = '';
  Genero? _genero;

  @override
  void dispose() {
    salon.removeListener(notifyListeners);
    super.dispose();
  }

  String get busqueda => _busqueda;
  Genero? get genero => _genero;

  // ---- Totales (de todos los clientes, sin filtros) ----

  int get total => salon.clientes.length;

  int get totalMujeres =>
      salon.clientes.where((c) => c.genero == Genero.mujer).length;

  int get totalHombres =>
      salon.clientes.where((c) => c.genero == Genero.hombre).length;

  // ---- Lista filtrada ----

  /// Búsqueda por nombre o teléfono, sin distinguir mayúsculas ni acentos,
  /// combinada con el filtro de género. Ordenada por nombre.
  List<Cliente> get clientes {
    final q = normalizar(_busqueda.trim());
    final qTelefono = q.replaceAll(' ', '');

    final lista = salon.clientes.where((c) {
      if (_genero != null && c.genero != _genero) return false;
      if (q.isEmpty) return true;
      final porNombre = normalizar(c.nombre).contains(q);
      final porTelefono = qTelefono.isNotEmpty && c.telefono.contains(qTelefono);
      return porNombre || porTelefono;
    }).toList();

    lista.sort((a, b) => normalizar(a.nombre).compareTo(normalizar(b.nombre)));
    return lista;
  }

  int cantidadTurnos(Cliente c) => salon.cantidadTurnosDeCliente(c.id);

  List<Turno> historial(Cliente c) => salon.turnosDeCliente(c.id);

  // ---- Acciones de filtro ----

  void buscar(String texto) {
    if (texto == _busqueda) return;
    _busqueda = texto;
    notifyListeners();
  }

  void filtrarGenero(Genero? genero) {
    if (genero == _genero) return;
    _genero = genero;
    notifyListeners();
  }

  // ---- Validaciones del formulario (mensajes del diseño) ----

  String? validarNombre(String? valor) =>
      Cliente.nombreValido(valor ?? '') ? null : 'Escribe entre 3 y 60 caracteres';

  String? validarTelefono(String? valor, {String? excluirId}) {
    final t = (valor ?? '').trim();
    if (!Cliente.telefonoValido(t)) return 'Debe tener exactamente 8 dígitos';
    if (salon.telefonoEnUso(t, excluirId: excluirId)) {
      return 'Ya existe un cliente con este teléfono';
    }
    return null;
  }

  String? validarGenero(Genero? genero) =>
      genero == null ? 'Selecciona un género' : null;

  /// El correo es opcional: solo se valida si se escribió algo.
  String? validarCorreo(String? valor) {
    final c = (valor ?? '').trim();
    if (c.isEmpty) return null;
    return Cliente.correoValido(c) ? null : 'Escribe un correo válido';
  }

  // ---- Operaciones (las reglas viven en SalonViewModel) ----

  Resultado<Cliente> registrar({
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) =>
      salon.registrarCliente(
        nombre: nombre,
        telefono: telefono,
        genero: genero,
        correo: correo,
      );

  Resultado<Cliente> editar({
    required String id,
    required String nombre,
    required String telefono,
    required Genero genero,
    String? correo,
  }) =>
      salon.editarCliente(
        id: id,
        nombre: nombre,
        telefono: telefono,
        genero: genero,
        correo: correo,
      );

  Resultado<Cliente> eliminar(String id) => salon.eliminarCliente(id);
}
