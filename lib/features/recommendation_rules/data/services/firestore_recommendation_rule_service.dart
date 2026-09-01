import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oculist/features/recommendation_rules/domain/models/recommendation_weights.dart';

class FirestoreRecommendationRuleService {
  FirestoreRecommendationRuleService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _document =>
      _firestore.collection('configuracion').doc('recomendacion');

  Future<RecommendationWeights> getWeights() async {
    final snapshot = await _document.get();
    return RecommendationWeights.fromMap(snapshot.data());
  }

  Future<void> saveWeights(RecommendationWeights weights) {
    return _document.set({
      ...weights.toMap(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }
}
