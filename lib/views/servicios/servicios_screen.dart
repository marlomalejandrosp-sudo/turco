import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/app_images.dart';
import '../../core/formato.dart';
import '../../models/enums.dart';
import '../../models/flujo_turno.dart';
import '../../models/servicio.dart';
import '../../viewmodels/servicios_viewmodel.dart';
import '../../widgets/acciones_turno.dart';
import '../../widgets/estado_vacio.dart';

/// Catálogo de servicios en cuadrícula. Al tocar uno se abre el formulario
/// de turno con ese servicio ya elegido (el dato viaja con `extra`).
class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key, required this.deps});

  final AppDependencies deps;

  Future<void> _reservar(BuildContext context, Servicio s) async {
    final r = await context.push<TurnoGuardado>(
      '/turno/nuevo',
      extra: DatosInicialesTurno(servicioId: s.id),
    );
    if (r != null && context.mounted) {
      mostrarTurnoGuardado(context, deps, r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = deps.servicios;
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final servicios = vm.servicios;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Servicios',
                    style: tema.textTheme.titleLarge?.copyWith(fontSize: 20)),
                Text('Toca un servicio para reservar',
                    style: tema.textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          body: LayoutBuilder(
            builder: (context, c) {
              // 2 columnas (<600 dp), 3 (600-840) o 4 (>840).
              final columnas = ServiciosViewModel.columnasPara(c.maxWidth);
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    sliver: SliverToBoxAdapter(child: _Filtros(vm: vm)),
                  ),
                  if (servicios.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EstadoVacio(
                        icono: Icons.search_off,
                        titulo: 'Sin resultados',
                        mensaje: 'Ningún servicio coincide con los filtros.',
                        accion: TextButton(
                          onPressed: vm.limpiarFiltros,
                          child: const Text('Quitar filtros'),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnas,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 196,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _TarjetaServicio(
                            servicio: servicios[i],
                            onTap: () => _reservar(context, servicios[i]),
                          ),
                          childCount: servicios.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.vm});

  final ServiciosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: vm.categoria == null,
                onSelected: (_) => vm.seleccionarCategoria(null),
              ),
              for (final c in CategoriaServicio.values) ...[
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(c.etiqueta),
                  selected: vm.categoria == c,
                  onSelected: (_) => vm.seleccionarCategoria(c),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<Publico?>(
          segments: const [
            ButtonSegment<Publico?>(value: null, label: Text('Todos')),
            ButtonSegment<Publico?>(
                value: Publico.mujeres, label: Text('Mujeres')),
            ButtonSegment<Publico?>(
                value: Publico.hombres, label: Text('Hombres')),
          ],
          selected: {vm.publico},
          onSelectionChanged: (s) => vm.seleccionarPublico(s.first),
        ),
      ],
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({required this.servicio, required this.onTap});

  final Servicio servicio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colores.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  height: 84,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      AppImages.categoria(servicio.categoria),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                servicio.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formato.minutos(servicio.duracionMin),
                    style: tema.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  Text(
                    Formato.precio(servicio.precio),
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colores.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colores.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(
                    servicio.publico.etiqueta,
                    style: tema.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colores.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
