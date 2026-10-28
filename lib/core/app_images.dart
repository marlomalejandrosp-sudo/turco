import '../models/enums.dart';

/// Rutas de los recursos gráficos, para evitar errores de tipeo.
abstract final class AppImages {
  static const logo = 'assets/images/logo.png';

  static const catCorte = 'assets/images/cat_corte.png';
  static const catColor = 'assets/images/cat_color.png';
  static const catBarba = 'assets/images/cat_barba.png';
  static const catPeinado = 'assets/images/cat_peinado.png';
  static const catTratamiento = 'assets/images/cat_tratamiento.png';

  static const avatares = [
    'assets/images/avatar_1.png',
    'assets/images/avatar_2.png',
    'assets/images/avatar_3.png',
    'assets/images/avatar_4.png',
    'assets/images/avatar_5.png',
  ];

  /// Imagen de cada categoría de servicio.
  static String categoria(CategoriaServicio c) => switch (c) {
        CategoriaServicio.corte => catCorte,
        CategoriaServicio.color => catColor,
        CategoriaServicio.barba => catBarba,
        CategoriaServicio.peinado => catPeinado,
        CategoriaServicio.tratamiento => catTratamiento,
      };
}
