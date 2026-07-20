import 'package:aakashvani/domain/models/user.dart';

abstract interface class IAuthRepository {
  /// Throws [AuthException] on invalid credentials.
  Future<User> loginWithCredentials(String email, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
