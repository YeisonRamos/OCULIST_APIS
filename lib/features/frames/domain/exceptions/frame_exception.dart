class FrameException implements Exception {
  const FrameException(this.message);

  final String message;

  @override
  String toString() => message;
}
