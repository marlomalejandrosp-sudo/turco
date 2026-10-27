/// Categorías del catálogo de servicios.
enum CategoriaServicio {
  corte('Corte'),
  color('Color'),
  barba('Barba'),
  peinado('Peinado'),
  tratamiento('Tratamiento');

  const CategoriaServicio(this.etiqueta);
  final String etiqueta;
}

/// Público al que se dirige un servicio.
enum Publico {
  mujeres('Mujeres'),
  hombres('Hombres'),
  unisex('Unisex');

  const Publico(this.etiqueta);
  final String etiqueta;
}

/// Género de un cliente.
enum Genero {
  mujer('Mujer'),
  hombre('Hombre');

  const Genero(this.etiqueta);
  final String etiqueta;

  /// Público que se selecciona por defecto para este cliente.
  Publico get publicoPorDefecto =>
      this == Genero.mujer ? Publico.mujeres : Publico.hombres;
}

/// Estado de un turno.
enum EstadoTurno {
  programado('Programado', 'Program.'),
  completado('Completado', 'Complet.'),
  cancelado('Cancelado', 'Cancel.');

  const EstadoTurno(this.etiqueta, this.etiquetaCorta);
  final String etiqueta;
  final String etiquetaCorta;
}
