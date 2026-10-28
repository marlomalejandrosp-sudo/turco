import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/formato.dart';
import '../../core/navegacion.dart';
import '../../models/flujo_turno.dart';
import '../../models/turno.dart';
import '../../widgets/acciones_turno.dart';
import '../../widgets/estado_turno_badge.dart';
import '../../widgets/estado_vacio.dart';

/// Detalle de un turno (/turno/:id). Solo lectura si ya no está programado.
class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key, required this.deps, required this.turnoId});

  final AppDependencies deps;
  final String turnoId;

  Future<void> _editar(BuildContext context) async {
    final r = await context.push<TurnoGuardado>('/turno/$turnoId/editar');
    // El resultado sigue su camino hacia la Agenda, que muestra el aviso.
    if (r != null && context.mounted) volverOAgenda(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final salon = deps.salon;

    return ListenableBuilder(
      listenable: salon,
      builder: (context, _) {
        final turno = salon.turnoPorId(turnoId);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Volver',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => volverOAgenda(context),
            ),
            title: Text('Detalle del turno',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20)),
          ),
          body: turno == null
              ? EstadoVacio(
                  icono: Icons.search_off,
                  titulo: 'No encontramos este turno',
                  mensaje: 'El turno no existe o ya no está disponible.',
                  accion: FilledButton.icon(
                    onPressed: () => context.go('/agenda'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver a la agenda'),
                  ),
                )
              : _Contenido(
                  deps: deps,
                  turno: turno,
                  onEditar: () => _editar(context),
                ),
        );
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.deps,
    required this.turno,
    required this.onEditar,
  });

  final AppDependencies deps;
  final Turno turno;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final salon = deps.salon;
    final cliente = salon.clientePorId(turno.clienteId);
    final estilista = salon.estilistaPorId(turno.estilistaId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Dato(
                    icono: Icons.person_outline,
                    etiqueta: 'Cliente',
                    valor: cliente == null
                        ? '—'
                        : '${cliente.nombre} · ${Formato.telefono(cliente.telefono)}',
                  ),
                  _Dato(
                    icono: Icons.content_cut,
                    etiqueta: 'Estilista',
                    valor: estilista?.nombre ?? '—',
                  ),
                  _Dato(
                    icono: Icons.event_outlined,
                    etiqueta: 'Fecha',
                    valor: Formato.fechaLarga(turno.inicio),
                  ),
                  _Dato(
                    icono: Icons.schedule,
                    etiqueta: 'Horario',
                    valor: Formato.rangoHoras(turno.inicio, turno.fin),
                  ),
                  _Dato(
                    icono: Icons.timelapse,
                    etiqueta: 'Duración total',
                    valor: Formato.duracion(turno.duracionMin),
                  ),
                  _Dato(
                    icono: Icons.flag_outlined,
                    etiqueta: 'Estado',
                    hijo: Align(
                      alignment: Alignment.centerLeft,
                      child: EstadoTurnoBadge(estado: turno.estado),
                    ),
                  ),
                  _Dato(
                    icono: Icons.add_circle_outline,
                    etiqueta: 'Creado',
                    valor:
                        '${Formato.fechaCorta(turno.creadoEn)} ${Formato.hora(turno.creadoEn)}',
                  ),
                  _Dato(
                    icono: Icons.update,
                    etiqueta: 'Última modificación',
                    valor:
                        '${Formato.fechaCorta(turno.modificadoEn)} ${Formato.hora(turno.modificadoEn)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Servicios
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servicios', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final s in turno.servicios)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(s.nombre,
                                style: tema.textTheme.bodyMedium
                                    ?.copyWith(color: colores.onSurface)),
                          ),
                          Text(Formato.minutos(s.duracionMin),
                              style: tema.textTheme.bodyMedium),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 56,
                            child: Text(Formato.precio(s.precio),
                                textAlign: TextAlign.end,
                                style: tema.textTheme.bodyMedium
                                    ?.copyWith(color: colores.onSurface)),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: Text('Total', style: tema.textTheme.titleMedium)),
                      Text(
                        Formato.precio(turno.total),
                        style: tema.textTheme.titleMedium
                            ?.copyWith(color: colores.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notas: área con scroll propio, no desborda con textos largos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notas', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            turno.notas ?? 'Sin notas',
                            style: tema.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Acciones: solo para turnos programados
          if (turno.esEditable) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      completarConConfirmacion(context, salon, turno),
                  icon: const Icon(Icons.check),
                  label: const Text('Completar'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colores.error,
                    side: BorderSide(color: colores.error),
                  ),
                  onPressed: () =>
                      cancelarConConfirmacion(context, salon, turno),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.etiqueta,
    this.valor,
    this.hijo,
  });

  final IconData icono;
  final String etiqueta;
  final String? valor;
  final Widget? hijo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: tema.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: tema.textTheme.labelSmall),
                const SizedBox(height: 2),
                hijo ??
                    Text(valor ?? '',
                        style: tema.textTheme.titleMedium
                            ?.copyWith(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
