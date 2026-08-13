import 'package:oculist/features/authentication/domain/models/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile> getUserById(String uid);
}
