import 'enums.dart';

/// Un cliente registrado en el salón.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
    required this.fechaRegistro,
  });

  final String id;
  final String nombre;

  /// Siempre 8 dígitos, sin espacios.
  final String telefono;
  final Genero genero;
  final String? correo;
  final DateTime fechaRegistro;

  String get inicial => nombre.isEmpty ? '?' : nombre[0].toUpperCase();

  // ---- Reglas de validación (viven en el modelo) ----

  static final RegExp _regTelefono = RegExp(r'^\d{8}$');
  static final RegExp _regCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const int nombreMin = 3;
  static const int nombreMax = 60;

  /// El teléfono debe tener exactamente 8 dígitos.
  static bool telefonoValido(String valor) => _regTelefono.hasMatch(valor);

  /// Formato básico de correo electrónico.
  static bool correoValido(String valor) => _regCorreo.hasMatch(valor);

  /// El nombre debe tener entre 3 y 60 caracteres (sin contar espacios
  /// de los extremos).
  static bool nombreValido(String valor) {
    final largo = valor.trim().length;
    return largo >= nombreMin && largo <= nombreMax;
  }

  @override
  bool operator ==(Object other) => other is Cliente && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
