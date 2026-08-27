class FaceValidationResult {
  const FaceValidationResult._({required this.isValid, required this.message});

  const FaceValidationResult.valid()
    : this._(isValid: true, message: 'Rostro detectado correctamente.');

  const FaceValidationResult.invalid(String message)
    : this._(isValid: false, message: message);

  final bool isValid;
  final String message;
}
