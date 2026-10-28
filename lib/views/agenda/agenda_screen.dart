import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/formato.dart';
import '../../models/enums.dart';
import '../../models/flujo_turno.dart';
import '../../models/reglas_salon.dart';
import '../../models/turno.dart';
import '../../viewmodels/agenda_viewmodel.dart';
import '../../widgets/acciones_turno.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/tarjeta_turno.dart';

/// Pantalla inicial: los turnos de un día, con filtros y resumen.
/// Acepta el parámetro de consulta `estilista` (/agenda?estilista=3).
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, required this.deps, this.estilistaId});

  final AppDependencies deps;
  final String? estilistaId;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  AgendaViewModel get vm => widget.deps.agenda;

  @override
  void initState() {
    super.initState();
    _aplicarParametro();
  }

  @override
  void didUpdateWidget(covariant AgendaScreen anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.estilistaId != widget.estilistaId) _aplicarParametro();
  }

  void _aplicarParametro() {
    final id = widget.estilistaId;
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) vm.seleccionarEstilista(id);
    });
  }

  Future<void> _nuevoTurno() async {
    final r = await context.push<TurnoGuardado>(
      '/turno/nuevo',
      extra: DatosInicialesTurno(fecha: vm.fecha),
    );
    if (r != null && mounted) mostrarTurnoGuardado(context, widget.deps, r);
  }

  Future<void> _abrirDetalle(Turno t) async {
    final r = await context.push<TurnoGuardado>('/turno/${t.id}');
    if (r != null && mounted) mostrarTurnoGuardado(context, widget.deps, r);
  }

  Future<void> _elegirFecha() async {
    final hoy = ReglasSalon.soloFecha(widget.deps.salon.ahora);
    final elegida = await showDatePicker(
      context: context,
      initialDate: vm.fecha,
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 2),
      helpText: 'Elegir fecha',
    );
    if (elegida != null) vm.irAFecha(elegida);
  }

  Future<void> _acciones(Turno t) async {
    if (!t.esEditable) return;
    final salon = widget.deps.salon;
    final accion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Completar'),
              onTap: () => Navigator.of(ctx).pop('completar'),
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined,
                  color: Theme.of(ctx).colorScheme.error),
              title: const Text('Cancelar turno'),
              onTap: () => Navigator.of(ctx).pop('cancelar'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || accion == null) return;
    if (accion == 'completar') {
      await completarConConfirmacion(context, salon, t);
    } else {
      await cancelarConConfirmacion(context, salon, t);
    }
  }

  Future<void> _elegirTema() {
    final tema = widget.deps.tema;
    return showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListenableBuilder(
        listenable: tema,
        builder: (ctx, _) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (modo, texto, icono) in const [
                (ThemeMode.system, 'Automático (sistema)', Icons.brightness_auto),
                (ThemeMode.light, 'Claro', Icons.light_mode_outlined),
                (ThemeMode.dark, 'Oscuro', Icons.dark_mode_outlined),
              ])
                ListTile(
                  leading: Icon(icono),
                  title: Text(texto),
                  trailing: tema.modo == modo ? const Icon(Icons.check) : null,
                  onTap: () {
                    tema.cambiar(modo);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final turnos = vm.turnos;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/logo.png',
                      width: 32, height: 32),
                ),
                const SizedBox(width: 12),
                const Text('Turco'),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Cambiar tema',
                icon: const Icon(Icons.brightness_6_outlined),
                onPressed: _elegirTema,
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _nuevoTurno,
            backgroundColor: tema.colorScheme.primaryContainer,
            foregroundColor: tema.colorScheme.onPrimaryContainer,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo turno'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            // El índice 0 es la cabecera; después, los turnos (o el aviso).
            itemCount: 1 + (turnos.isEmpty ? 1 : turnos.length),
            itemBuilder: (context, i) {
              if (i == 0) return _Cabecera(vm: vm, onElegirFecha: _elegirFecha);
              if (turnos.isEmpty) {
                return EstadoVacio(
                  icono: Icons.event_busy,
                  titulo: 'No hay turnos para este día',
                  mensaje:
                      'Crea el primer turno con el botón de abajo o cambia los filtros.',
                );
              }
              final t = turnos[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TarjetaTurno(
                  turno: t,
                  nombreCliente: vm.nombreCliente(t),
                  nombreEstilista: vm.nombreEstilista(t),
                  onTap: () => _abrirDetalle(t),
                  onLongPress: t.esEditable ? () => _acciones(t) : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.vm, required this.onElegirFecha});

  final AgendaViewModel vm;
  final VoidCallback onElegirFecha;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final resumen = vm.resumen;
    final estilistas = vm.salon.estilistas;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mes, semana anterior/siguiente y selector de fecha
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Semana anterior',
                icon: const Icon(Icons.chevron_left),
                onPressed: vm.semanaAnterior,
              ),
              Flexible(
                child: Text(
                  Formato.mesAnio(vm.fecha),
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.titleMedium
                      ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Semana siguiente',
                icon: const Icon(Icons.chevron_right),
                onPressed: vm.semanaSiguiente,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onElegirFecha,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: const Text('Elegir fecha'),
              ),
            ],
          ),

          // Los siete días de la semana (ListView.builder horizontal)
          LayoutBuilder(
            builder: (context, c) {
              final ancho = c.maxWidth / 7;
              return SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, i) {
                    final dia = vm.diasDeLaSemana[i];
                    return SizedBox(
                      width: ancho,
                      child: _DiaSemana(
                        dia: dia,
                        seleccionado: vm.esSeleccionado(dia),
                        esHoy: vm.esHoy(dia),
                        onTap: () => vm.irAFecha(dia),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Domingo: salón cerrado',
            style: tema.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: vm.diaCerrado
                  ? tema.colorScheme.error
                  : tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),

          // Resumen del día
          Row(
            children: [
              Expanded(
                child: _Resumen(
                  valor: '${resumen.programados}',
                  etiqueta: 'Programados',
                  color: tema.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Resumen(
                  valor: '${resumen.completados}',
                  etiqueta: 'Completados',
                  color: tema.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Resumen(
                  valor: Formato.precio(resumen.ingresoEstimado),
                  etiqueta: 'Ingreso est.',
                  color: tema.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Filtro por estilista
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: vm.estilistaId == null,
                  onSelected: (_) => vm.seleccionarEstilista(null),
                ),
                for (final e in estilistas) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(e.primerNombre),
                    selected: vm.estilistaId == e.id,
                    onSelected: (_) => vm.seleccionarEstilista(e.id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Filtro por estado
          SegmentedButton<EstadoTurno?>(
            segments: [
              const ButtonSegment<EstadoTurno?>(
                  value: null, label: Text('Todos')),
              for (final e in EstadoTurno.values)
                ButtonSegment<EstadoTurno?>(
                  value: e,
                  label: Text(e.etiquetaCorta, overflow: TextOverflow.ellipsis),
                ),
            ],
            selected: {vm.estado},
            onSelectionChanged: (s) => vm.seleccionarEstado(s.first),
          ),
        ],
      ),
    );
  }
}

class _DiaSemana extends StatelessWidget {
  const _DiaSemana({
    required this.dia,
    required this.seleccionado,
    required this.esHoy,
    required this.onTap,
  });

  final DateTime dia;
  final bool seleccionado;
  final bool esHoy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final cerrado = !ReglasSalon.estaAbierto(dia);

    final colorTexto = seleccionado
        ? colores.onPrimary
        : (cerrado ? colores.outline : colores.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: seleccionado ? colores.primary : colores.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: esHoy && !seleccionado
              ? BorderSide(color: colores.primary)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Formato.diaSemanaCorto(dia),
                style: tema.textTheme.labelSmall?.copyWith(color: colorTexto),
              ),
              const SizedBox(height: 2),
              Text(
                '${dia.day}',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorTexto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: tema.textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Text(etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
