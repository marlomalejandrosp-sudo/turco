import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_dependencies.dart';
import '../core/formato.dart';
import '../models/flujo_turno.dart';
import '../models/turno.dart';
import '../viewmodels/salon_viewmodel.dart';
import 'dialogo_confirmacion.dart';

void _aviso(BuildContext context, String texto) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(texto)));
}

/// Pide confirmación y marca el turno como completado.
Future<void> completarConConfirmacion(
  BuildContext context,
  SalonViewModel salon,
  Turno turno,
) async {
  final cliente = salon.clientePorId(turno.clienteId)?.nombre ?? 'el cliente';
  final si = await confirmar(
    context,
    titulo: '¿Marcar como completado?',
    mensaje:
        'El turno de $cliente (${Formato.rangoHoras(turno.inicio, turno.fin)}) '
        'pasará a completado.',
    textoConfirmar: 'Completar',
    textoCancelar: 'Volver',
  );
  if (!si || !context.mounted) return;
  final r = salon.completarTurno(turno.id);
  _aviso(context, r.ok ? 'Turno completado' : r.error!);
}

/// Pide confirmación y cancela el turno (su horario queda libre).
Future<void> cancelarConConfirmacion(
  BuildContext context,
  SalonViewModel salon,
  Turno turno,
) async {
  final cliente = salon.clientePorId(turno.clienteId)?.nombre ?? 'el cliente';
  final si = await confirmar(
    context,
    titulo: '¿Cancelar este turno?',
    mensaje:
        'El horario de $cliente (${Formato.rangoHoras(turno.inicio, turno.fin)}) '
        'quedará libre. Esta acción no se puede deshacer.',
    textoConfirmar: 'Cancelar turno',
    textoCancelar: 'Volver',
    destructivo: true,
  );
  if (!si || !context.mounted) return;
  final r = salon.cancelarTurno(turno.id);
  _aviso(context, r.ok ? 'Turno cancelado' : r.error!);
}

/// Aviso tras guardar un turno: la Agenda se ubica en su fecha y muestra
/// un SnackBar con la opción "Ver".
void mostrarTurnoGuardado(
  BuildContext context,
  AppDependencies deps,
  TurnoGuardado guardado,
) {
  deps.agenda.irAFecha(guardado.fecha);
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Text(
        '${guardado.esNuevo ? 'Turno guardado' : 'Turno actualizado'} para el '
        '${Formato.fechaGuardado(guardado.fecha)}',
      ),
      action: SnackBarAction(
        label: 'Ver',
        onPressed: () => context.go('/agenda'),
      ),
    ),
  );
}
