import 'servicio.dart';

/// Un estilista del salón (solo lectura).
class Estilista {
  const Estilista({
    required this.id,
    required this.nombre,
    required this.avatar,
    required this.servicioIds,
  });

  final String id;
  final String nombre;
  final String avatar;
  final List<String> servicioIds;

  String get inicial => nombre.isEmpty ? '?' : nombre[0].toUpperCase();

  String get primerNombre => nombre.split(' ').first;

  bool realiza(Servicio servicio) => servicioIds.contains(servicio.id);

  /// True si el estilista realiza TODOS los servicios indicados.
  bool realizaTodos(Iterable<Servicio> servicios) =>
      servicios.every(realiza);

  @override
  bool operator ==(Object other) => other is Estilista && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
