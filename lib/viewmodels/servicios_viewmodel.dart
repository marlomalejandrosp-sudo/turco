import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/servicio.dart';
import 'salon_viewmodel.dart';

/// Estado de la pantalla Servicios: filtros por categoría y por público.
class ServiciosViewModel extends ChangeNotifier {
  ServiciosViewModel(this.salon);

  final SalonViewModel salon;

  CategoriaServicio? _categoria;
  Publico? _publico;

  CategoriaServicio? get categoria => _categoria;
  Publico? get publico => _publico;

  bool get hayFiltros => _categoria != null || _publico != null;

  /// Servicios que cumplen ambos filtros. Un servicio unisex aparece
  /// al filtrar por mujeres y por hombres.
  List<Servicio> get servicios => salon.servicios
      .where((s) =>
          (_categoria == null || s.categoria == _categoria) &&
          s.sirveA(_publico))
      .toList();

  /// Columnas de la cuadrícula según el ancho disponible (en dp):
  /// 2 en menos de 600, 3 entre 600 y 840, y 4 en más de 840.
  static int columnasPara(double ancho) {
    if (ancho < 600) return 2;
    if (ancho <= 840) return 3;
    return 4;
  }

  void seleccionarCategoria(CategoriaServicio? categoria) {
    if (categoria == _categoria) return;
    _categoria = categoria;
    notifyListeners();
  }

  void seleccionarPublico(Publico? publico) {
    if (publico == _publico) return;
    _publico = publico;
    notifyListeners();
  }

  void limpiarFiltros() {
    _categoria = null;
    _publico = null;
    notifyListeners();
  }
}
