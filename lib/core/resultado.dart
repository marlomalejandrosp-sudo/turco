/// Resultado de una operación de negocio: o trae un valor o trae un
/// mensaje de error listo para mostrar al usuario.
class Resultado<T> {
  const Resultado._({this.valor, this.error});

  /// Operación correcta.
  factory Resultado.ok([T? valor]) => Resultado<T>._(valor: valor);

  /// Operación rechazada, con el motivo.
  factory Resultado.fallo(String mensaje) => Resultado<T>._(error: mensaje);

  final T? valor;
  final String? error;

  bool get ok => error == null;
}
