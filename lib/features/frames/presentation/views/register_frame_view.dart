import 'package:flutter/material.dart';
import 'package:oculist/features/frames/presentation/view_models/register_frame_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final _styleController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

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
      estilo: _styleController.text,
      imagePath: _selectedImage?.path,
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
      _styleController.clear();

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

  Future<void> _selectImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 75,
    );

    if (!mounted || image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
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

                _buildField(
                  controller: _styleController,
                  label: 'Estilo',
                  icon: Icons.auto_awesome_outlined,
                  viewModel: viewModel,
                  fieldName:
                      'el estilo (clásico, moderno, elegante, deportivo o casual)',
                ),
                const SizedBox(height: 8),

                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 42),
                        SizedBox(height: 8),
                        Text('Sin fotografía seleccionada'),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: viewModel.isSaving ? null : _selectImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _selectedImage == null
                        ? 'Seleccionar fotografía'
                        : 'Cambiar fotografía',
                  ),
                ),

                const SizedBox(height: 20),

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
