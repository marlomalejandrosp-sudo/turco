import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/formato.dart';
import '../../models/estilista.dart';
import '../../viewmodels/estilistas_viewmodel.dart';

/// Lista de estilistas con un SliverAppBar plegable.
/// Al tocar uno se va a la Agenda con su filtro, enviando el identificador
/// como parámetro de consulta: /agenda?estilista=3
class EstilistasScreen extends StatelessWidget {
  const EstilistasScreen({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    final vm = deps.estilistas;
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final lista = vm.estilistas;
        final subtitulo =
            '${Formato.plural(lista.length, 'profesional', 'profesionales')} · '
            '${Formato.plural(vm.totalProgramadosHoy, 'turno programado', 'turnos programados')} hoy';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsetsDirectional.only(start: 16, bottom: 12),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estilistas',
                          style: tema.textTheme.titleLarge
                              ?.copyWith(fontSize: 20)),
                      Text(subtitulo,
                          style: tema.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TarjetaEstilista(
                        estilista: lista[i],
                        vm: vm,
                        onTap: () {
                          deps.agenda.seleccionarEstilista(lista[i].id);
                          context.go('/agenda?estilista=${lista[i].id}');
                        },
                      ),
                    ),
                    childCount: lista.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TarjetaEstilista extends StatelessWidget {
  const _TarjetaEstilista({
    required this.estilista,
    required this.vm,
    required this.onTap,
  });

  final Estilista estilista;
  final EstilistasViewModel vm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final hoy = vm.programadosHoy(estilista);
    final porCategoria = vm.serviciosPorCategoria(estilista);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colores.secondaryContainer,
                backgroundImage: AssetImage(estilista.avatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estilista.nombre,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in porCategoria.keys)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colores.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              child: Text(
                                c.etiqueta,
                                style: tema.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colores.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hoy == 0
                          ? 'Sin turnos hoy'
                          : '${Formato.plural(hoy, 'turno', 'turnos')} hoy',
                      style: tema.textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hoy == 0
                            ? colores.onSurfaceVariant
                            : colores.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colores.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
