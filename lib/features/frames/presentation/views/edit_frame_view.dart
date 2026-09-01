import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/frames/presentation/view_models/edit_frame_view_model.dart';
import 'package:provider/provider.dart';

class EditFrameView extends StatefulWidget {
  const EditFrameView({super.key});

  @override
  State<EditFrameView> createState() => _EditFrameViewState();
}

class _EditFrameViewState extends State<EditFrameView> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _shapeController = TextEditingController();
  final _materialController = TextEditingController();
  final _sizeController = TextEditingController();
  final _styleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFrame());
  }

  Future<void> _loadFrame() async {
    final viewModel = context.read<EditFrameViewModel>();

    await viewModel.loadFrame();

    if (!mounted) {
      return;
    }

    final frame = viewModel.frame;

    if (frame == null) {
      return;
    }

    _codeController.text = frame.codigo;
    _brandController.text = frame.marca;
    _modelController.text = frame.modelo;
    _colorController.text = frame.color;
    _shapeController.text = frame.forma;
    _materialController.text = frame.material;
    _sizeController.text = frame.talla;
    _styleController.text = frame.estilo;
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final viewModel = context.read<EditFrameViewModel>();

    final success = await viewModel.updateFrame(
      codigo: _codeController.text,
      marca: _brandController.text,
      modelo: _modelController.text,
      color: _colorController.text,
      forma: _shapeController.text,
      material: _materialController.text,
      talla: _sizeController.text,
      estilo: _styleController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montura actualizada correctamente.')),
      );

      context.pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible actualizar la montura.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _shapeController.dispose();
    _materialController.dispose();
    _sizeController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditFrameViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar montura')),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.frame == null
          ? Center(
              child: Text(
                viewModel.errorMessage ?? 'No fue posible cargar la montura.',
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      controller: _codeController,
                      label: 'Código',
                      viewModel: viewModel,
                    ),
                    _field(
                      controller: _brandController,
                      label: 'Marca',
                      viewModel: viewModel,
                    ),
                    _field(
                      controller: _modelController,
                      label: 'Modelo',
                      viewModel: viewModel,
                    ),
                    _field(
                      controller: _colorController,
                      label: 'Color',
                      viewModel: viewModel,
                    ),
                    _field(
                      controller: _shapeController,
                      label: 'Forma',
                      viewModel: viewModel,
                    ),
                    _field(
                      controller: _materialController,
                      label: 'Material',
                      viewModel: viewModel,
                    ),
                    _field(
                      controller: _sizeController,
                      label: 'Talla',
                      viewModel: viewModel,
                    ),

                    _field(
                      controller: _styleController,
                      label: 'Estilo',
                      viewModel: viewModel,
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: viewModel.isSaving ? null : _save,
                        icon: viewModel.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          viewModel.isSaving
                              ? 'Guardando...'
                              : 'Guardar cambios',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required EditFrameViewModel viewModel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          return viewModel.validateRequired(value, label.toLowerCase());
        },
      ),
    );
  }
}
