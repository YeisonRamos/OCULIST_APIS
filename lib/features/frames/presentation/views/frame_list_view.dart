import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/core/widgets/app_branding.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
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
      body: WarmGradientBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              FadeSlideIn(
                child: TextField(
                  key: const Key('frame_search_field'),
                  onChanged: viewModel.search,
                  decoration: const InputDecoration(
                    labelText: 'Buscar montura',
                    hintText: 'Marca, modelo, código...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent(viewModel)),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: frames.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final frame = frames[index];
        return FadeSlideIn(
          delay: Duration(milliseconds: index.clamp(0, 5) * 70),
          child: _FrameCard(
            frame: frame,
            onTap: () => context.push('/monturas/${frame.id}'),
          ),
        );
      },
    );
  }
}

class _FrameCard extends StatelessWidget {
  const _FrameCard({required this.frame, required this.onTap});
  final Frame frame;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = frame.disponible;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 86,
                  height: 70,
                  child: _Thumbnail(imageUrl: frame.imagenUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      frame.nombreCompleto,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${frame.codigo} • ${frame.forma} • ${frame.color}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF756765),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: available
                            ? const Color(0xFFE8F5E9)
                            : AppTheme.blush,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        available ? 'Disponible' : 'No disponible',
                        style: TextStyle(
                          color: available
                              ? const Color(0xFF26713A)
                              : AppTheme.crimson,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.crimson),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return const ColoredBox(
        color: AppTheme.blush,
        child: Icon(
          Icons.remove_red_eye_outlined,
          color: AppTheme.crimson,
          size: 32,
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppTheme.blush,
        child: Icon(Icons.broken_image_outlined, color: AppTheme.crimson),
      ),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const ColoredBox(
              color: AppTheme.blush,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
    );
  }
}
