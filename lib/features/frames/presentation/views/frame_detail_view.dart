import 'package:flutter/material.dart';
import 'package:oculist/features/frames/presentation/view_models/frame_detail_view_model.dart';
import 'package:provider/provider.dart';

class FrameDetailView extends StatefulWidget {
  const FrameDetailView({super.key});

  @override
  State<FrameDetailView> createState() => _FrameDetailViewState();
}

class _FrameDetailViewState extends State<FrameDetailView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FrameDetailViewModel>().loadFrame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FrameDetailViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la montura')),
      body: _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, FrameDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(viewModel.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    final frame = viewModel.frame;

    if (frame == null) {
      return const Center(
        child: Text('No se encontró información de la montura.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CircleAvatar(
            radius: 42,
            child: Icon(Icons.remove_red_eye_outlined, size: 44),
          ),

          const SizedBox(height: 20),

          Text(
            frame.nombreCompleto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 6),

          Text(
            frame.codigo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          _DetailItem(
            icon: Icons.business_outlined,
            title: 'Marca',
            value: frame.marca,
          ),

          _DetailItem(
            icon: Icons.style_outlined,
            title: 'Modelo',
            value: frame.modelo,
          ),

          _DetailItem(
            icon: Icons.palette_outlined,
            title: 'Color',
            value: frame.color,
          ),

          _DetailItem(
            icon: Icons.category_outlined,
            title: 'Forma',
            value: frame.forma,
          ),

          _DetailItem(
            icon: Icons.layers_outlined,
            title: 'Material',
            value: frame.material,
          ),

          _DetailItem(
            icon: Icons.straighten_outlined,
            title: 'Talla',
            value: frame.talla,
          ),

          _DetailItem(
            icon: Icons.inventory_2_outlined,
            title: 'Disponibilidad',
            value: frame.disponible ? 'Disponible' : 'No disponible',
          ),

          _DetailItem(
            icon: Icons.verified_user_outlined,
            title: 'Estado',
            value: frame.activo ? 'Activa' : 'Inactiva',
          ),

          _DetailItem(
            icon: Icons.calendar_today_outlined,
            title: 'Fecha de registro',
            value: _formatDate(frame.fechaRegistro),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
