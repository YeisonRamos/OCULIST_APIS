import 'package:flutter/foundation.dart';
import 'package:oculist/features/recommendation_rules/data/services/firestore_recommendation_rule_service.dart';
import 'package:oculist/features/recommendation_rules/domain/models/recommendation_weights.dart';

class RecommendationRulesViewModel extends ChangeNotifier {
  RecommendationRulesViewModel({FirestoreRecommendationRuleService? service})
    : _service = service ?? FirestoreRecommendationRuleService();
  final FirestoreRecommendationRuleService _service;
  RecommendationWeights weights = const RecommendationWeights();
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  Future<void> load() async {
    try {
      weights = await _service.getWeights();
    } catch (_) {
      errorMessage = 'Se usarán los valores predeterminados.';
    }
    isLoading = false;
    notifyListeners();
  }

  void update({int? shape, int? size, int? color, int? style}) {
    weights = RecommendationWeights(
      shape: shape ?? weights.shape,
      size: size ?? weights.size,
      color: color ?? weights.color,
      style: style ?? weights.style,
    );
    notifyListeners();
  }

  Future<bool> save() async {
    if (weights.total != 100) {
      errorMessage = 'La suma de los pesos debe ser exactamente 100.';
      notifyListeners();
      return false;
    }
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.saveWeights(weights);
      return true;
    } catch (_) {
      errorMessage = 'No fue posible guardar las reglas.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
