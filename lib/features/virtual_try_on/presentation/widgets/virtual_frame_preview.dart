import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';

class VirtualFramePreview extends StatefulWidget {
  const VirtualFramePreview({
    required this.facePhotoUrl,
    required this.frameImageUrl,
    required this.geometry,
    super.key,
  });

  final String facePhotoUrl;
  final String frameImageUrl;
  final FaceGeometry geometry;

  @override
  State<VirtualFramePreview> createState() => _VirtualFramePreviewState();
}

class _VirtualFramePreviewState extends State<VirtualFramePreview> {
  late Future<Uint8List> _transparentFrame;

  @override
  void initState() {
    super.initState();
    _transparentFrame = _loadTransparentFrame();
  }

  @override
  void didUpdateWidget(covariant VirtualFramePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frameImageUrl != widget.frameImageUrl) {
      _transparentFrame = _loadTransparentFrame();
    }
  }

  Future<Uint8List> _loadTransparentFrame() async {
    final data = await NetworkAssetBundle(
      Uri.parse(widget.frameImageUrl),
    ).load(widget.frameImageUrl);
    return compute(_removeLightBackground, data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final geometry = widget.geometry;
    final aspectRatio = geometry.imageWidth / geometry.imageHeight;
    return AspectRatio(
      aspectRatio: aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : .75,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final leftX = geometry.leftEyeX * constraints.maxWidth;
          final leftY = geometry.leftEyeY * constraints.maxHeight;
          final rightX = geometry.rightEyeX * constraints.maxWidth;
          final rightY = geometry.rightEyeY * constraints.maxHeight;
          final eyeDistance = math.sqrt(
            math.pow(rightX - leftX, 2) + math.pow(rightY - leftY, 2),
          );
          final centerX = (leftX + rightX) / 2;
          final centerY = (leftY + rightY) / 2;
          final overlayWidth = (eyeDistance * 2.65).clamp(
            constraints.maxWidth * .42,
            constraints.maxWidth * .9,
          );
          final overlayHeight = overlayWidth * .5;
          final angle = math.atan2(rightY - leftY, rightX - leftX);

          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.facePhotoUrl,
                  fit: BoxFit.fill,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: Color(0xFFFFE8E1),
                    child: Icon(Icons.broken_image_outlined, size: 52),
                  ),
                ),
                Positioned(
                  left: centerX - overlayWidth / 2,
                  top: centerY - overlayHeight * .48,
                  width: overlayWidth,
                  height: overlayHeight,
                  child: Transform.rotate(
                    angle: angle,
                    child: FutureBuilder<Uint8List>(
                      future: _transparentFrame,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          );
                        }
                        if (snapshot.hasError) {
                          return const SizedBox.shrink();
                        }
                        return const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Uint8List _removeLightBackground(Uint8List bytes) {
  final decoded = image_lib.decodeImage(bytes);
  if (decoded == null) return bytes;

  final processed = decoded.convert(numChannels: 4);
  for (final pixel in processed) {
    if (pixel.a == 0) continue;

    final red = pixel.r.toDouble();
    final green = pixel.g.toDouble();
    final blue = pixel.b.toDouble();
    final minimum = math.min(red, math.min(green, blue));
    final maximum = math.max(red, math.max(green, blue));
    final isNeutral = maximum - minimum < 24;

    if (isNeutral && minimum >= 242) {
      pixel.a = 0;
    } else if (isNeutral && minimum > 205) {
      final opacity = ((242 - minimum) / 37).clamp(0.0, 1.0);
      pixel.a = (pixel.a * opacity).round();
    }
  }

  return Uint8List.fromList(image_lib.encodePng(processed));
}
