abstract interface class AuthRepository {
  Future<String> signIn({required String email, required String password});

  Future<void> signOut();

  String? get currentUserId;

  Stream<String?> authStateChanges();
}
