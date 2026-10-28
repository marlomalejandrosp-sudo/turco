import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/formato.dart';
import '../../models/cliente.dart';
import '../../models/enums.dart';
import '../../models/estilista.dart';
import '../../models/flujo_turno.dart';
import '../../models/reglas_salon.dart';
import '../../models/turno.dart';
import '../../viewmodels/salon_viewmodel.dart';
import '../../viewmodels/turno_form_viewmodel.dart';
import '../../widgets/campo_selector.dart';
import '../../widgets/dialogo_confirmacion.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/formulario_cliente.dart';

/// Formulario para crear (/turno/nuevo) y editar (/turno/:id/editar) un
/// turno. Toda la lógica vive en [TurnoFormViewModel]; aquí solo se muestra.
class TurnoFormScreen extends StatefulWidget {
  const TurnoFormScreen({
    super.key,
    required this.deps,
    this.turnoId,
    this.datos,
  });

  final AppDependencies deps;

  /// Identificador del turno a editar; null si se está creando.
  final String? turnoId;

  /// Datos iniciales enviados con `extra` desde otras pantallas.
  final DatosInicialesTurno? datos;

  @override
  State<TurnoFormScreen> createState() => _TurnoFormScreenState();
}

class _TurnoFormScreenState extends State<TurnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notas = TextEditingController();

  // Un FocusNode por campo, para llevar el foco al primer error.
  final _focoCliente = FocusNode();
  final _focoServicios = FocusNode();
  final _focoEstilista = FocusNode();
  final _focoFecha = FocusNode();
  final _focoHora = FocusNode();
  final _focoNotas = FocusNode();

  TurnoFormViewModel? _vm;
  Turno? _turno;
  bool _noDisponible = false;
  bool _salidaLibre = false;

  @override
  void initState() {
    super.initState();
    final id = widget.turnoId;
    if (id != null) {
      _turno = widget.deps.salon.turnoPorId(id);
      if (_turno == null || !_turno!.esEditable) {
        _noDisponible = true;
        return;
      }
    }
    final vm = TurnoFormViewModel(
      salon: widget.deps.salon,
      turnoEditado: _turno,
      datos: widget.datos,
    );
    vm.addListener(_alCambiar);
    _notas.text = vm.notas;
    _vm = vm;
  }

  @override
  void dispose() {
    _vm?.removeListener(_alCambiar);
    _vm?.dispose();
    _notas.dispose();
    for (final f in [
      _focoCliente,
      _focoServicios,
      _focoEstilista,
      _focoFecha,
      _focoHora,
      _focoNotas,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  /// Muestra los avisos del ViewModel (por ejemplo, "el estilista ya no
  /// realiza todos los servicios").
  void _alCambiar() {
    final aviso = _vm?.consumirAviso();
    if (aviso != null && mounted) _mensaje(aviso);
  }

  void _mensaje(String texto) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Cierra la pantalla sin volver a preguntar por cambios sin guardar.
  void _salir([TurnoGuardado? resultado]) {
    setState(() => _salidaLibre = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(resultado);
      } else {
        context.go('/agenda');
      }
    });
  }

  Future<bool> _confirmarDescartar() {
    return confirmar(
      context,
      titulo: '¿Descartar los cambios?',
      mensaje:
          'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.',
      textoConfirmar: 'Descartar',
      textoCancelar: 'Seguir editando',
      destructivo: true,
    );
  }

  Future<void> _intentarSalir() async {
    final vm = _vm!;
    if (!vm.hayCambios || await _confirmarDescartar()) {
      if (mounted) _salir();
    }
  }

  void _guardar() {
    final vm = _vm!;
    if (!_formKey.currentState!.validate()) {
      _enfocarPrimerError(vm);
      return;
    }
    final r = vm.guardar();
    if (!r.ok) {
      _mensaje(r.error!);
      return;
    }
    _salir(r.valor);
  }

  /// Lleva el foco (y el scroll) al primer campo con error.
  void _enfocarPrimerError(TurnoFormViewModel vm) {
    final orden = <(String?, FocusNode)>[
      (vm.validarCliente(), _focoCliente),
      (vm.validarServicios(), _focoServicios),
      (vm.validarEstilista(), _focoEstilista),
      (vm.validarFecha(), _focoFecha),
      (vm.validarHora(), _focoHora),
    ];
    for (final (error, nodo) in orden) {
      if (error != null) {
        nodo.requestFocus();
        final ctx = nodo.context;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 250),
            alignment: 0.1,
          );
        }
        return;
      }
    }
  }

  // ---------------------------------------------------------------
  // Selectores
  // ---------------------------------------------------------------

  Future<void> _elegirCliente(TurnoFormViewModel vm) async {
    final c = await showModalBottomSheet<Cliente>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          for (final c in vm.clientesDisponibles)
            ListTile(
              leading: CircleAvatar(child: Text(c.inicial)),
              title: Text(c.nombre),
              subtitle: Text(
                  '${Formato.telefono(c.telefono)} · ${c.genero.etiqueta}'),
              selected: vm.cliente == c,
              onTap: () => Navigator.of(ctx).pop(c),
            ),
        ],
      ),
    );
    if (c != null) vm.seleccionarCliente(c);
  }

  Future<void> _crearCliente(TurnoFormViewModel vm) async {
    final c = await mostrarFormularioCliente(context, widget.deps.clientes);
    if (c != null && mounted) vm.seleccionarCliente(c);
  }

  Future<void> _elegirEstilista(TurnoFormViewModel vm) async {
    final e = await showModalBottomSheet<Estilista>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          for (final e in vm.estilistasDisponibles)
            ListTile(
              leading: CircleAvatar(backgroundImage: AssetImage(e.avatar)),
              title: Text(e.nombre),
              selected: vm.estilista == e,
              onTap: () => Navigator.of(ctx).pop(e),
            ),
        ],
      ),
    );
    if (e != null) vm.seleccionarEstilista(e);
  }

  Future<void> _elegirFecha(TurnoFormViewModel vm) async {
    final hoy = ReglasSalon.soloFecha(widget.deps.salon.ahora);
    final inicial = vm.fecha != null && vm.fechaPermitida(vm.fecha!)
        ? vm.fecha!
        : vm.primeraFechaPermitida();
    final f = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      selectableDayPredicate: (d) => ReglasSalon.estaAbierto(d),
      helpText: 'Elegir fecha',
    );
    if (f != null) vm.elegirFecha(f);
  }

  // ---------------------------------------------------------------
  // Pantalla
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    if (_noDisponible || vm == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/agenda'),
          ),
          title: const Text('Editar turno'),
        ),
        body: EstadoVacio(
          icono: Icons.search_off,
          titulo: 'No se puede editar',
          mensaje: _turno == null
              ? 'El turno no existe o ya no está disponible.'
              : 'Solo se pueden editar los turnos programados.',
          accion: FilledButton.icon(
            onPressed: () => context.go('/agenda'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver a la agenda'),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return PopScope(
          // Atrás con cambios sin guardar: se pide confirmación.
          canPop: _salidaLibre || !vm.hayCambios,
          onPopInvokedWithResult: (salio, _) async {
            if (salio) return;
            if (await _confirmarDescartar() && mounted) _salir();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Volver',
                icon: const Icon(Icons.arrow_back),
                onPressed: _intentarSalir,
              ),
              title: Text(
                vm.esEdicion ? 'Editar turno' : 'Nuevo turno',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  _seccionCliente(vm),
                  const SizedBox(height: 20),
                  _seccionServicios(vm),
                  const SizedBox(height: 20),
                  _seccionEstilista(vm),
                  const SizedBox(height: 20),
                  _seccionFecha(vm),
                  const SizedBox(height: 20),
                  _seccionHora(vm),
                  const SizedBox(height: 20),
                  _seccionNotas(vm),
                ],
              ),
            ),
            bottomNavigationBar: _BarraInferior(
              vm: vm,
              onGuardar: _guardar,
              onCancelar: _intentarSalir,
            ),
          ),
        );
      },
    );
  }

  Widget _seccionCliente(TurnoFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampoSelector(
          key: ValueKey('cliente-${vm.cliente?.id}'),
          etiqueta: 'Cliente',
          valor: vm.cliente?.nombre,
          focusNode: _focoCliente,
          validator: vm.validarCliente,
          onTap: () => _elegirCliente(vm),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _crearCliente(vm),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Crear cliente nuevo'),
          ),
        ),
      ],
    );
  }

  Widget _seccionServicios(TurnoFormViewModel vm) {
    final tema = Theme.of(context);
    final grupos = vm.serviciosPorCategoria;
    final ids = vm.serviciosElegidos.map((s) => s.id).join(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Servicios para', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<Publico?>(
          segments: const [
            ButtonSegment<Publico?>(value: null, label: Text('Todos')),
            ButtonSegment<Publico?>(
                value: Publico.mujeres, label: Text('Mujeres')),
            ButtonSegment<Publico?>(
                value: Publico.hombres, label: Text('Hombres')),
          ],
          selected: {vm.publico},
          onSelectionChanged: (s) => vm.cambiarPublico(s.first),
        ),
        const SizedBox(height: 12),
        Text('Servicios', style: tema.textTheme.titleMedium),
        FormField<bool>(
          key: ValueKey('servicios-$ids'),
          validator: (_) => vm.validarServicios(),
          builder: (estado) {
            return Focus(
              focusNode: _focoServicios,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entrada in grupos.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 2),
                      child: Text(
                        entrada.key.etiqueta.toUpperCase(),
                        style: tema.textTheme.labelSmall
                            ?.copyWith(letterSpacing: 0.8),
                      ),
                    ),
                    for (final s in entrada.value)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: vm.estaSeleccionado(s),
                        onChanged: (_) => vm.alternarServicio(s),
                        title: Text(s.nombre),
                        subtitle: Text(
                            '${Formato.minutos(s.duracionMin)} · ${Formato.precio(s.precio)}'),
                      ),
                  ],
                  if (estado.errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        estado.errorText!,
                        style: tema.textTheme.labelSmall
                            ?.copyWith(color: tema.colorScheme.error),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _seccionEstilista(TurnoFormViewModel vm) {
    return CampoSelector(
      key: ValueKey('estilista-${vm.estilista?.id}-${vm.serviciosElegidos.length}'),
      etiqueta: 'Estilista',
      valor: vm.estilista?.nombre,
      focusNode: _focoEstilista,
      habilitado: vm.estilistasHabilitados,
      ayuda: vm.estilistasHabilitados
          ? 'Solo se muestran estilistas que realizan todos los servicios elegidos.'
          : 'Primero elige los servicios',
      validator: vm.validarEstilista,
      onTap: () => _elegirEstilista(vm),
    );
  }

  Widget _seccionFecha(TurnoFormViewModel vm) {
    return CampoSelector(
      key: ValueKey('fecha-${vm.fecha}'),
      etiqueta: 'Fecha',
      valor: vm.fecha == null ? null : Formato.fechaLarga(vm.fecha!),
      focusNode: _focoFecha,
      icono: Icons.calendar_today_outlined,
      validator: vm.validarFecha,
      onTap: () => _elegirFecha(vm),
    );
  }

  Widget _seccionHora(TurnoFormViewModel vm) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final franjas = vm.franjas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hora de inicio', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _Leyenda(
              color: colores.surface,
              borde: colores.outline,
              texto: 'Libre',
            ),
            _Leyenda(
              color: colores.onSurface.withValues(alpha: 0.12),
              texto: 'No disponible',
            ),
            _Leyenda(color: colores.secondaryContainer, texto: 'Elegida'),
          ],
        ),
        const SizedBox(height: 8),
        FormField<bool>(
          key: ValueKey('hora-${vm.hora}'),
          validator: (_) => vm.validarHora(),
          builder: (estado) {
            return Focus(
              focusNode: _focoHora,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (franjas.isEmpty)
                    Text('Elige una fecha válida para ver los horarios.',
                        style: tema.textTheme.bodyMedium)
                  else ...[
                    // Cuadrícula dentro de un ListView: shrinkWrap y sin
                    // scroll propio, para que no haya errores de altura.
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 40,
                      ),
                      itemCount: franjas.length,
                      itemBuilder: (context, i) {
                        final f = franjas[i];
                        return ChoiceChip(
                          showCheckmark: false,
                          padding: EdgeInsets.zero,
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(
                              Formato.hora(f.inicio),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          selected: vm.hora == f.inicio,
                          onSelected:
                              f.disponible ? (_) => vm.elegirHora(f.inicio) : null,
                        );
                      },
                    ),
                    if (!vm.hayFranjasLibres)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'No quedan horarios libres para esta combinación. '
                          'Prueba con otra fecha, estilista o servicios.',
                          style: tema.textTheme.bodyMedium
                              ?.copyWith(color: colores.error),
                        ),
                      ),
                  ],
                  if (estado.errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        estado.errorText!,
                        style: tema.textTheme.labelSmall
                            ?.copyWith(color: colores.error),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _seccionNotas(TurnoFormViewModel vm) {
    return TextFormField(
      controller: _notas,
      focusNode: _focoNotas,
      maxLines: 4,
      minLines: 2,
      maxLength: SalonViewModel.notasMax,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Notas (opcional)',
        alignLabelWithHint: true,
      ),
      onChanged: vm.cambiarNotas,
      onFieldSubmitted: (_) => _focoNotas.unfocus(),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.color, required this.texto, this.borde});

  final Color color;
  final Color? borde;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borde == null ? null : Border.all(color: borde!),
          ),
          child: const SizedBox(width: 14, height: 14),
        ),
        const SizedBox(width: 6),
        Text(texto, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

/// Resumen siempre visible (duración, fin, precio) y botones.
class _BarraInferior extends StatelessWidget {
  const _BarraInferior({
    required this.vm,
    required this.onGuardar,
    required this.onCancelar,
  });

  final TurnoFormViewModel vm;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final fin = vm.horaFin;
    final estilo = tema.textTheme.titleMedium?.copyWith(fontSize: 15);

    return Material(
      color: colores.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Formato.duracion(vm.duracionTotal), style: estilo),
                  Text(fin == null ? 'Fin —' : 'Fin ${Formato.hora(fin)}',
                      style: estilo),
                  Text(
                    Formato.precio(vm.precioTotal),
                    style: estilo?.copyWith(color: colores.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancelar,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onGuardar,
                      child: const Text('Guardar turno'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
