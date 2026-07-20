import 'package:dio/dio.dart';
import 'package:aakashvani/core/api/api_client.dart';
import 'package:aakashvani/core/api/auth_token_holder.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/role.dart';
import 'package:aakashvani/features/auth/domain/i_auth_repository.dart';

class ApiAuthRepository implements IAuthRepository {
  ApiAuthRepository(this._client, this._tokenHolder);

  final ApiClient _client;
  final AuthTokenHolder _tokenHolder;

  @override
  Future<User> loginWithCredentials(String email, String password) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login/',
        data: {'email': email.trim(), 'password': password},
      );
      final data = response.data;
      if (data == null) {
        throw const AuthException('Empty response from server.');
      }
      final token = data['token'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;
      if (token == null || userJson == null) {
        throw const AuthException('Invalid response from server.');
      }
      _tokenHolder.setToken(token);
      return _userFromJson(userJson, token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Invalid email or password.');
      }
      throw AuthException(_dioMessage(e));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = _tokenHolder.token;
    if (token == null || token.isEmpty) return null;
    try {
      final response =
          await _client.dio.get<Map<String, dynamic>>('/auth/me/');
      final data = response.data;
      if (data == null) return null;
      return _userFromJson(data, token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _tokenHolder.clear();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post<void>('/auth/logout/');
    } on DioException {
      // Best-effort logout; always clear local token.
    } finally {
      _tokenHolder.clear();
    }
  }

  User _userFromJson(Map<String, dynamic> json, String token) {
    final roleName = json['role'] as String? ?? 'viewer';
    final zoneScope = (json['zone_scope'] as List?)?.cast<String>() ?? const [];
    return User(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['email'] as String? ?? '',
      role: Role.values.byName(roleName),
      zoneScope: zoneScope,
      token: token,
    );
  }

  String _dioMessage(DioException e) {
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] != null) {
      return detail['detail'].toString();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not reach the server. Check your network and API URL.';
    }
    return e.message ?? 'Request failed.';
  }
}
