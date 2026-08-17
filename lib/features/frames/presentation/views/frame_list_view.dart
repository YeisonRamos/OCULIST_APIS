import 'package:flutter/material.dart';
import 'package:oculist/features/frames/presentation/view_models/frame_list_view_model.dart';
import 'package:provider/provider.dart';

class FrameListView extends StatefulWidget {
  const FrameListView({super.key});

  @override
  State<FrameListView> createState() => _FrameListViewState();
}

class _FrameListViewState extends State<FrameListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FrameListViewModel>().loadFrames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FrameListViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de monturas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('frame_search_field'),
              onChanged: viewModel.search,
              decoration: const InputDecoration(
                labelText: 'Buscar montura',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(child: _buildContent(viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(FrameListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(viewModel.errorMessage!, textAlign: TextAlign.center),
      );
    }

    final frames = viewModel.filteredFrames;

    if (frames.isEmpty) {
      return const Center(child: Text('No se encontraron monturas.'));
    }

    return ListView.separated(
      itemCount: frames.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final frame = frames[index];

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.remove_red_eye_outlined),
            ),
            title: Text(frame.nombreCompleto),
            subtitle: Text('${frame.codigo} • ${frame.forma} • ${frame.color}'),
            trailing: Text(frame.disponible ? 'Disponible' : 'No disponible'),
          ),
        );
      },
    );
  }
}
