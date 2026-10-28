import 'data/datos_prueba.dart';
import 'viewmodels/agenda_viewmodel.dart';
import 'viewmodels/clientes_viewmodel.dart';
import 'viewmodels/estilistas_viewmodel.dart';
import 'viewmodels/salon_viewmodel.dart';
import 'viewmodels/servicios_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

/// Reúne los ViewModels de la app. Se crean una sola vez al iniciar y
/// viven mientras la app esté abierta, por eso cada pestaña conserva su
/// estado (búsqueda, filtros y fecha) al cambiar de destino.
///
/// Se pasan a las pantallas por constructor: sin paquetes externos.
class AppDependencies {
  AppDependencies._({
    required this.salon,
    required this.tema,
    required this.agenda,
    required this.clientes,
    required this.servicios,
    required this.estilistas,
  });

  /// Carga los datos de prueba en memoria y crea todos los ViewModels.
  factory AppDependencies.crear() {
    final ahora = DateTime.now();
    final salon = SalonViewModel(
      servicios: DatosPrueba.servicios,
      estilistas: DatosPrueba.estilistas,
      clientes: DatosPrueba.clientes(ahora),
      turnos: DatosPrueba.turnos(ahora),
    );
    return AppDependencies._(
      salon: salon,
      tema: ThemeViewModel(),
      agenda: AgendaViewModel(salon),
      clientes: ClientesViewModel(salon),
      servicios: ServiciosViewModel(salon),
      estilistas: EstilistasViewModel(salon),
    );
  }

  final SalonViewModel salon;
  final ThemeViewModel tema;
  final AgendaViewModel agenda;
  final ClientesViewModel clientes;
  final ServiciosViewModel servicios;
  final EstilistasViewModel estilistas;
}
