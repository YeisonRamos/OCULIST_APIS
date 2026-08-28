class FaceGeometry {
  const FaceGeometry({
    required this.leftEyeX,
    required this.leftEyeY,
    required this.rightEyeX,
    required this.rightEyeY,
    required this.imageWidth,
    required this.imageHeight,
  });

  final double leftEyeX;
  final double leftEyeY;
  final double rightEyeX;
  final double rightEyeY;
  final double imageWidth;
  final double imageHeight;

  Map<String, dynamic> toMap() => {
    'leftEyeX': leftEyeX,
    'leftEyeY': leftEyeY,
    'rightEyeX': rightEyeX,
    'rightEyeY': rightEyeY,
    'imageWidth': imageWidth,
    'imageHeight': imageHeight,
  };

  static FaceGeometry? fromMap(Object? value) {
    if (value is! Map) return null;
    double? number(String key) => (value[key] as num?)?.toDouble();
    final leftEyeX = number('leftEyeX');
    final leftEyeY = number('leftEyeY');
    final rightEyeX = number('rightEyeX');
    final rightEyeY = number('rightEyeY');
    final imageWidth = number('imageWidth');
    final imageHeight = number('imageHeight');
    if ([
      leftEyeX,
      leftEyeY,
      rightEyeX,
      rightEyeY,
      imageWidth,
      imageHeight,
    ].contains(null)) {
      return null;
    }
    return FaceGeometry(
      leftEyeX: leftEyeX!,
      leftEyeY: leftEyeY!,
      rightEyeX: rightEyeX!,
      rightEyeY: rightEyeY!,
      imageWidth: imageWidth!,
      imageHeight: imageHeight!,
    );
  }
}
