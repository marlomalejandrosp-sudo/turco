import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/formato.dart';
import '../../models/cliente.dart';
import '../../models/enums.dart';
import '../../models/flujo_turno.dart';
import '../../viewmodels/clientes_viewmodel.dart';
import '../../widgets/acciones_turno.dart';
import '../../widgets/dialogo_confirmacion.dart';
import '../../widgets/estado_turno_badge.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/formulario_cliente.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late final TextEditingController _buscador;

  ClientesViewModel get vm => widget.deps.clientes;

  @override
  void initState() {
    super.initState();
    // Recupera el texto si la pestaña se reconstruye.
    _buscador = TextEditingController(text: vm.busqueda);
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _nuevo() async {
    final c = await mostrarFormularioCliente(context, vm);
    if (c != null && mounted) _mensaje('Cliente registrado: ${c.nombre}');
  }

  Future<void> _editar(Cliente c) async {
    final editado = await mostrarFormularioCliente(context, vm, cliente: c);
    if (editado != null && mounted) _mensaje('Cliente actualizado');
  }

  Future<void> _nuevoTurno(Cliente c) async {
    final r = await context.push<TurnoGuardado>(
      '/turno/nuevo',
      extra: DatosInicialesTurno(clienteId: c.id),
    );
    if (r != null && mounted) mostrarTurnoGuardado(context, widget.deps, r);
  }

  Future<void> _eliminar(Cliente c) async {
    // Con turnos programados, la regla del ViewModel lo rechaza y explica.
    if (widget.deps.salon.programadosDeCliente(c.id) > 0) {
      final r = vm.eliminar(c.id);
      _mensaje(r.error ?? 'No se puede eliminar este cliente.');
      return;
    }
    final si = await confirmar(
      context,
      titulo: '¿Eliminar a ${c.nombre}?',
      mensaje: 'Se eliminará el cliente junto con su historial de turnos '
          'completados y cancelados.',
      textoConfirmar: 'Eliminar',
      destructivo: true,
    );
    if (!si || !mounted) return;
    final r = vm.eliminar(c.id);
    _mensaje(r.ok ? 'Cliente eliminado' : r.error!);
  }

  Future<void> _verDetalle(Cliente c) async {
    final accion = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DetalleCliente(vm: vm, clienteId: c.id),
    );
    if (!mounted || accion == null) return;
    switch (accion) {
      case 'turno':
        await _nuevoTurno(c);
      case 'editar':
        await _editar(c);
      case 'eliminar':
        await _eliminar(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final lista = vm.clientes;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Text('Clientes',
                style: tema.textTheme.titleLarge?.copyWith(fontSize: 20)),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _nuevo,
            backgroundColor: tema.colorScheme.primaryContainer,
            foregroundColor: tema.colorScheme.onPrimaryContainer,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Nuevo cliente'),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            // El índice 0 es la cabecera (búsqueda, filtro y totales).
            itemCount: 1 + (lista.isEmpty ? 1 : lista.length),
            separatorBuilder: (context, indice) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (i == 0) return _cabecera(context);
              if (lista.isEmpty) {
                return EstadoVacio(
                  icono: Icons.person_search,
                  titulo: vm.total == 0
                      ? 'Aún no hay clientes'
                      : 'No encontramos clientes',
                  mensaje: vm.total == 0
                      ? 'Registra el primero con el botón de abajo.'
                      : 'Prueba con otro nombre, teléfono o filtro.',
                );
              }
              final c = lista[i - 1];
              return _TarjetaCliente(
                cliente: c,
                turnos: vm.cantidadTurnos(c),
                onTap: () => _verDetalle(c),
              );
            },
          ),
        );
      },
    );
  }

  Widget _cabecera(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _buscador,
          onChanged: vm.buscar,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o teléfono',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: vm.busqueda.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Borrar búsqueda',
                    onPressed: () {
                      _buscador.clear();
                      vm.buscar('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<Genero?>(
          segments: const [
            ButtonSegment<Genero?>(value: null, label: Text('Todos')),
            ButtonSegment<Genero?>(value: Genero.mujer, label: Text('Mujeres')),
            ButtonSegment<Genero?>(
                value: Genero.hombre, label: Text('Hombres')),
          ],
          selected: {vm.genero},
          onSelectionChanged: (s) => vm.filtrarGenero(s.first),
        ),
        const SizedBox(height: 10),
        Text(
          '${Formato.plural(vm.total, 'cliente', 'clientes')} · '
          '${Formato.plural(vm.totalMujeres, 'mujer', 'mujeres')} · '
          '${Formato.plural(vm.totalHombres, 'hombre', 'hombres')}',
          style: tema.textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _TarjetaCliente extends StatelessWidget {
  const _TarjetaCliente({
    required this.cliente,
    required this.turnos,
    required this.onTap,
  });

  final Cliente cliente;
  final int turnos;
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colores.primaryContainer,
                foregroundColor: colores.onPrimaryContainer,
                child: Text(cliente.inicial),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formato.telefono(cliente.telefono)} · '
                      '${cliente.genero.etiqueta}',
                      style: tema.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Formato.plural(turnos, 'turno', 'turnos'),
                style: tema.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colores.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja con los datos del cliente, su historial y las opciones.
/// Se cierra devolviendo 'turno', 'editar' o 'eliminar'.
class _DetalleCliente extends StatelessWidget {
  const _DetalleCliente({required this.vm, required this.clienteId});

  final ClientesViewModel vm;
  final String clienteId;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final c = vm.salon.clientePorId(clienteId);
    if (c == null) return const SizedBox.shrink();
    final historial = vm.historial(c);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colores.primaryContainer,
                foregroundColor: colores.onPrimaryContainer,
                child: Text(c.inicial, style: tema.textTheme.titleMedium),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nombre, style: tema.textTheme.titleLarge),
                    Text(Formato.telefono(c.telefono),
                        style: tema.textTheme.bodyMedium),
                    if (c.correo != null)
                      Text(c.correo!, style: tema.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Historial de turnos · ${historial.length}',
              style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (historial.isEmpty)
            Text('Este cliente todavía no tiene turnos.',
                style: tema.textTheme.bodyMedium)
          else
            for (final t in historial)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${Formato.diaMes(t.inicio)} · ${t.serviciosTexto}',
                        style: tema.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    EstadoTurnoBadge(estado: t.estado),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop('turno'),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo turno'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop('editar'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: colores.error),
                onPressed: () => Navigator.of(context).pop('eliminar'),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
