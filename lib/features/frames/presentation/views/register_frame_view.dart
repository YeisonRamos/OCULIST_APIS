import 'package:flutter/material.dart';
import 'package:oculist/features/frames/presentation/view_models/register_frame_view_model.dart';
import 'package:provider/provider.dart';

class RegisterFrameView extends StatefulWidget {
  const RegisterFrameView({super.key});

  @override
  State<RegisterFrameView> createState() => _RegisterFrameViewState();
}

class _RegisterFrameViewState extends State<RegisterFrameView> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _shapeController = TextEditingController();
  final _materialController = TextEditingController();
  final _sizeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _shapeController.dispose();
    _materialController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _registerFrame() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final viewModel = context.read<RegisterFrameViewModel>();

    final success = await viewModel.registerFrame(
      codigo: _codeController.text,
      marca: _brandController.text,
      modelo: _modelController.text,
      color: _colorController.text,
      forma: _shapeController.text,
      material: _materialController.text,
      talla: _sizeController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _formKey.currentState?.reset();

      _codeController.clear();
      _brandController.clear();
      _modelController.clear();
      _colorController.clear();
      _shapeController.clear();
      _materialController.clear();
      _sizeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montura registrada correctamente.')),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible registrar la montura.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterFrameViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar montura')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.remove_red_eye_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Nueva montura',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registra una montura disponible en la óptica OCULIST.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildField(
                  controller: _codeController,
                  label: 'Código',
                  icon: Icons.qr_code_rounded,
                  viewModel: viewModel,
                  fieldName: 'el código',
                ),

                _buildField(
                  controller: _brandController,
                  label: 'Marca',
                  icon: Icons.business_outlined,
                  viewModel: viewModel,
                  fieldName: 'la marca',
                ),

                _buildField(
                  controller: _modelController,
                  label: 'Modelo',
                  icon: Icons.style_outlined,
                  viewModel: viewModel,
                  fieldName: 'el modelo',
                ),

                _buildField(
                  controller: _colorController,
                  label: 'Color',
                  icon: Icons.palette_outlined,
                  viewModel: viewModel,
                  fieldName: 'el color',
                ),

                _buildField(
                  controller: _shapeController,
                  label: 'Forma',
                  icon: Icons.category_outlined,
                  viewModel: viewModel,
                  fieldName: 'la forma',
                ),

                _buildField(
                  controller: _materialController,
                  label: 'Material',
                  icon: Icons.layers_outlined,
                  viewModel: viewModel,
                  fieldName: 'el material',
                ),

                _buildField(
                  controller: _sizeController,
                  label: 'Talla',
                  icon: Icons.straighten_outlined,
                  viewModel: viewModel,
                  fieldName: 'la talla',
                ),

                const SizedBox(height: 12),

                FilledButton.icon(
                  key: const Key('register_frame_button'),
                  onPressed: viewModel.isSaving ? null : _registerFrame,
                  icon: viewModel.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    viewModel.isSaving ? 'Registrando...' : 'Registrar montura',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required RegisterFrameViewModel viewModel,
    required String fieldName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (value) {
          return viewModel.validateRequired(value, fieldName);
        },
      ),
    );
  }
}
