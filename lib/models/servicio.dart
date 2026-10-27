import 'enums.dart';

/// Un servicio del catálogo (solo lectura).
class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionMin,
    required this.precio,
    required this.publico,
  });

  final String id;
  final String nombre;
  final CategoriaServicio categoria;
  final int duracionMin;
  final int precio;
  final Publico publico;

  /// Indica si el servicio sirve al público elegido en un filtro.
  /// Con filtro `null` (Todos) siempre es true. Los servicios unisex
  /// sirven a mujeres y a hombres.
  bool sirveA(Publico? filtro) {
    if (filtro == null || publico == Publico.unisex) return true;
    return publico == filtro;
  }

  @override
  bool operator ==(Object other) => other is Servicio && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
