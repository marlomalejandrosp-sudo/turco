import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cliente.dart';
import '../models/enums.dart';
import '../viewmodels/clientes_viewmodel.dart';

/// Hoja inferior con el formulario de alta y edición de clientes.
/// La usan la pantalla Clientes y el formulario de turno.
/// Devuelve el cliente guardado, o null si se cancela.
Future<Cliente?> mostrarFormularioCliente(
  BuildContext context,
  ClientesViewModel vm, {
  Cliente? cliente,
}) {
  return showModalBottomSheet<Cliente>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _FormularioCliente(vm: vm, cliente: cliente),
  );
}

class _FormularioCliente extends StatefulWidget {
  const _FormularioCliente({required this.vm, this.cliente});

  final ClientesViewModel vm;
  final Cliente? cliente;

  @override
  State<_FormularioCliente> createState() => _FormularioClienteState();
}

class _FormularioClienteState extends State<_FormularioCliente> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _correo;
  final _foco = [FocusNode(), FocusNode(), FocusNode()];
  Genero? _genero;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombre = TextEditingController(text: c?.nombre ?? '');
    _telefono = TextEditingController(text: c?.telefono ?? '');
    _correo = TextEditingController(text: c?.correo ?? '');
    _genero = c?.genero;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    for (final f in _foco) {
      f.dispose();
    }
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final c = widget.cliente;
    final genero = _genero!;
    final r = c == null
        ? widget.vm.registrar(
            nombre: _nombre.text,
            telefono: _telefono.text,
            genero: genero,
            correo: _correo.text,
          )
        : widget.vm.editar(
            id: c.id,
            nombre: _nombre.text,
            telefono: _telefono.text,
            genero: genero,
            correo: _correo.text,
          );
    if (!r.ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(r.error!)));
      return;
    }
    Navigator.of(context).pop(r.valor);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final editando = widget.cliente != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(editando ? 'Editar cliente' : 'Nuevo cliente',
                  style: tema.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                focusNode: _foco[0],
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: widget.vm.validarNombre,
                onFieldSubmitted: (_) => _foco[1].requestFocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                focusNode: _foco[1],
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (v) =>
                    widget.vm.validarTelefono(v, excluirId: widget.cliente?.id),
                onFieldSubmitted: (_) => _foco[2].requestFocus(),
              ),
              const SizedBox(height: 12),
              FormField<Genero>(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => widget.vm.validarGenero(_genero),
                builder: (estado) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SegmentedButton<Genero>(
                        emptySelectionAllowed: true,
                        segments: [
                          for (final g in Genero.values)
                            ButtonSegment<Genero>(
                                value: g, label: Text(g.etiqueta)),
                        ],
                        selected: _genero == null ? <Genero>{} : {_genero!},
                        onSelectionChanged: (s) {
                          setState(() => _genero = s.isEmpty ? null : s.first);
                          estado.didChange(_genero);
                        },
                      ),
                      if (estado.errorText != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: Text(
                            estado.errorText!,
                            style: tema.textTheme.labelSmall
                                ?.copyWith(color: tema.colorScheme.error),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correo,
                focusNode: _foco[2],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration:
                    const InputDecoration(labelText: 'Correo (opcional)'),
                validator: widget.vm.validarCorreo,
                onFieldSubmitted: (_) => _guardar(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      child: const Text('Guardar cliente'),
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
