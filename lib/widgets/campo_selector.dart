import 'package:flutter/material.dart';

/// Campo de formulario que no se escribe: al tocarlo abre un selector.
/// Muestra el error de validación bajo el campo y acepta un [FocusNode].
class CampoSelector extends StatelessWidget {
  const CampoSelector({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.onTap,
    required this.validator,
    this.focusNode,
    this.ayuda,
    this.habilitado = true,
    this.icono = Icons.arrow_drop_down,
  });

  final String etiqueta;
  final String? valor;
  final VoidCallback onTap;

  /// Devuelve el mensaje de error o null si el valor es válido.
  final String? Function() validator;
  final FocusNode? focusNode;
  final String? ayuda;
  final bool habilitado;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      validator: (_) => validator(),
      builder: (estado) {
        return Focus(
          focusNode: focusNode,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: habilitado
                ? () {
                    focusNode?.requestFocus();
                    onTap();
                  }
                : null,
            child: InputDecorator(
              isEmpty: valor == null,
              decoration: InputDecoration(
                labelText: etiqueta,
                helperText: ayuda,
                helperMaxLines: 2,
                errorText: estado.errorText,
                enabled: habilitado,
                suffixIcon: Icon(icono),
              ),
              child: Text(valor ?? '', overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      },
    );
  }
}
