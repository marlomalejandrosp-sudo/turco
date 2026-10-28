import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import 'salon_viewmodel.dart';

/// Datos de la pantalla Estilistas.
class EstilistasViewModel extends ChangeNotifier {
  EstilistasViewModel(this.salon) {
    salon.addListener(notifyListeners);
  }

  final SalonViewModel salon;

  @override
  void dispose() {
    salon.removeListener(notifyListeners);
    super.dispose();
  }

  List<Estilista> get estilistas => salon.estilistas;

  int get totalProgramadosHoy => salon.totalProgramadosHoy;

  int programadosHoy(Estilista e) => salon.programadosHoy(e.id);

  /// Servicios que realiza el estilista, agrupados por categoría y en el
  /// orden de las categorías. Solo aparecen las categorías que realiza.
  Map<CategoriaServicio, List<Servicio>> serviciosPorCategoria(Estilista e) {
    final mapa = <CategoriaServicio, List<Servicio>>{};
    for (final categoria in CategoriaServicio.values) {
      final lista = salon.servicios
          .where((s) => s.categoria == categoria && e.realiza(s))
          .toList();
      if (lista.isNotEmpty) mapa[categoria] = lista;
    }
    return mapa;
  }
}
