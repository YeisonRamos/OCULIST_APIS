enum FaceShape {
  oval,
  round,
  square,
  oblong,
  triangular,
  heart;

  String get firestoreValue => name;

  String get label {
    switch (this) {
      case FaceShape.oval:
        return 'Ovalado';
      case FaceShape.round:
        return 'Redondo';
      case FaceShape.square:
        return 'Cuadrado';
      case FaceShape.oblong:
        return 'Alargado';
      case FaceShape.triangular:
        return 'Triangular';
      case FaceShape.heart:
        return 'Corazón';
    }
  }

  String get explanation {
    switch (this) {
      case FaceShape.oval:
        return 'Proporciones equilibradas y rostro ligeramente más largo que ancho.';
      case FaceShape.round:
        return 'Ancho y largo similares, con líneas faciales suaves.';
      case FaceShape.square:
        return 'Frente, pómulos y mandíbula de anchura similar.';
      case FaceShape.oblong:
        return 'Rostro notablemente más largo que ancho.';
      case FaceShape.triangular:
        return 'Mandíbula más ancha que la frente, con mayor peso visual en la parte inferior.';
      case FaceShape.heart:
        return 'Parte superior más ancha y mandíbula más estrecha.';
    }
  }

  static FaceShape? fromFirestore(String? value) {
    for (final shape in FaceShape.values) {
      if (shape.name == value) return shape;
    }
    return null;
  }
}
