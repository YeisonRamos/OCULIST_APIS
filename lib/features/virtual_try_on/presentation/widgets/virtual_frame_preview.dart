import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';

class VirtualFramePreview extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
          final overlayWidth = (eyeDistance * 2.35).clamp(
            constraints.maxWidth * .35,
            constraints.maxWidth * .82,
          );
          final overlayHeight = overlayWidth * .42;
          final angle = math.atan2(rightY - leftY, rightX - leftX);

          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  facePhotoUrl,
                  fit: BoxFit.fill,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: Color(0xFFFFE8E1),
                    child: Icon(Icons.broken_image_outlined, size: 52),
                  ),
                ),
                Positioned(
                  left: centerX - overlayWidth / 2,
                  top: centerY - overlayHeight * .47,
                  width: overlayWidth,
                  height: overlayHeight,
                  child: Transform.rotate(
                    angle: angle,
                    child: Image.network(
                      frameImageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
