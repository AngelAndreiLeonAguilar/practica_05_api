/// Auxiliares de lectura segura de campos JSON.
///
/// Convierten valores dinámicos a tipos de Dart y lanzan [FormatException]
/// cuando el contrato del API no se cumple, en lugar de fallar con un
/// `TypeError` difícil de diagnosticar.
library;

int leerEntero(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is int) return valor;
  if (valor is num) return valor.toInt();
  if (valor is String) {
    final numero = int.tryParse(valor);
    if (numero != null) return numero;
  }
  throw FormatException('El campo "$campo" no es un entero válido: $valor');
}

String leerTexto(Map<String, dynamic> json, String campo) {
  final valor = json[campo];
  if (valor is String) return valor;
  throw FormatException('El campo "$campo" no es texto válido: $valor');
}
