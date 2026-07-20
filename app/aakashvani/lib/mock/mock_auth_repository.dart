import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/features/auth/domain/i_auth_repository.dart';
import 'package:aakashvani/mock/seed_data.dart';

class MockAuthRepository implements IAuthRepository {
  User? _currentUser;

  @override
  Future<User> loginWithCredentials(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final entry = mockCredentials[email.trim().toLowerCase()];
    if (entry == null || entry.$1 != password) {
      throw const AuthException('Invalid email or password.');
    }
    final user = seedUsers.firstWhere((u) => u.id == entry.$2);
    _currentUser = user;
    return user;
  }

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}
