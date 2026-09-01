class RecommendationWeights {
  const RecommendationWeights({
    this.shape = 50,
    this.size = 25,
    this.color = 15,
    this.style = 10,
  });

  final int shape;
  final int size;
  final int color;
  final int style;

  int get total => shape + size + color + style;

  Map<String, dynamic> toMap() => {
    'forma': shape,
    'talla': size,
    'color': color,
    'estilo': style,
  };

  factory RecommendationWeights.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const RecommendationWeights();
    return RecommendationWeights(
      shape: (data['forma'] as num?)?.toInt() ?? 50,
      size: (data['talla'] as num?)?.toInt() ?? 25,
      color: (data['color'] as num?)?.toInt() ?? 15,
      style: (data['estilo'] as num?)?.toInt() ?? 10,
    );
  }
}
