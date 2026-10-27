/// Pasa a minúsculas y quita acentos, para buscar sin distinguir
/// mayúsculas ni tildes. "María" y "maria" dan el mismo resultado.
String normalizar(String texto) {
  const origen = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const destino = 'aaaaaeeeeiiiiooooouuuunc';
  final buffer = StringBuffer();
  for (final c in texto.toLowerCase().split('')) {
    final i = origen.indexOf(c);
    buffer.write(i >= 0 ? destino[i] : c);
  }
  return buffer.toString();
}
