import 'package:flutter/material.dart';

/// Tema global de Turco (Material 3, claro y oscuro).
///
/// Aquí vive TODO el estilo: paleta, tipografía, radios y componentes.
/// Las pantallas no escriben colores ni medidas sueltas: leen el tema con
/// `Theme.of(context)`.
abstract final class AppTheme {
  static const Color _semilla = Color(0xFF00695C);
  static const String _fuente = 'Poppins';

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get oscuro => _construir(Brightness.dark);

  static TextStyle _estilo(double tamano, FontWeight peso, Color color) {
    return TextStyle(
      fontFamily: _fuente,
      fontSize: tamano,
      fontWeight: peso,
      color: color,
    );
  }

  static ThemeData _construir(Brightness brillo) {
    final colores = ColorScheme.fromSeed(
      seedColor: _semilla,
      brightness: brillo,
    );

    // Escala tipográfica del diseño (Poppins).
    final textos = TextTheme(
      headlineSmall: _estilo(24, FontWeight.w600, colores.onSurface),
      titleLarge: _estilo(22, FontWeight.w600, colores.onSurface),
      titleMedium: _estilo(16, FontWeight.w500, colores.onSurface),
      bodyMedium: _estilo(14, FontWeight.w400, colores.onSurfaceVariant),
      labelSmall: _estilo(11, FontWeight.w500, colores.onSurfaceVariant),
    );

    // Radio 12 para botones y campos; radio 16 para tarjetas.
    final radio12 = BorderRadius.circular(12);
    final campo = OutlineInputBorder(borderRadius: radio12);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colores,
      fontFamily: _fuente,
      textTheme: textos,
      scaffoldBackgroundColor: colores.surface,

      // Barra superior
      appBarTheme: AppBarTheme(
        backgroundColor: colores.surface,
        foregroundColor: colores.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _estilo(22, FontWeight.w600, colores.onSurface),
      ),

      // Tarjetas: radio 16
      cardTheme: CardThemeData(
        color: colores.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Botones: radio 12
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radio12),
          textStyle: _estilo(14, FontWeight.w600, colores.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radio12),
          textStyle: _estilo(14, FontWeight.w600, colores.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radio12),
          textStyle: _estilo(14, FontWeight.w600, colores.primary),
        ),
      ),

      // Campos de texto: radio 12
      inputDecorationTheme: InputDecorationTheme(
        border: campo,
        enabledBorder: campo,
        focusedBorder: campo.copyWith(
          borderSide: BorderSide(color: colores.primary, width: 2),
        ),
        errorBorder: campo.copyWith(
          borderSide: BorderSide(color: colores.error),
        ),
        focusedErrorBorder: campo.copyWith(
          borderSide: BorderSide(color: colores.error, width: 2),
        ),
      ),

      // Chips de filtro: radio 8
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: _estilo(13, FontWeight.w500, colores.onSurfaceVariant),
      ),

      // Selector segmentado
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            _estilo(13, FontWeight.w500, colores.onSurface),
          ),
        ),
      ),

      // Botón flotante extendido
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        extendedTextStyle: _estilo(14, FontWeight.w600, colores.onPrimaryContainer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Barra de navegación inferior
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: colores.surfaceContainer,
        indicatorColor: colores.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: activo
                ? colores.onSecondaryContainer
                : colores.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return _estilo(
            12,
            activo ? FontWeight.w600 : FontWeight.w500,
            activo ? colores.onSurface : colores.onSurfaceVariant,
          );
        }),
      ),

      // Avisos
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radio12),
      ),

      // Hojas inferiores
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
      ),
    );
  }
}
