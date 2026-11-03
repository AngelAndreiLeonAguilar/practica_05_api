/// Error de dominio para fallas de red, HTTP o de formato JSON.
class ApiException implements Exception {
  const ApiException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
