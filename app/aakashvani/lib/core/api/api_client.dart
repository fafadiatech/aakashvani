import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/core/api/auth_token_holder.dart';
import 'package:aakashvani/core/config.dart';

class ApiClient {
  ApiClient({required this.tokenHolder, String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConfig.resolvedApiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenHolder.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final AuthTokenHolder tokenHolder;
  final Dio dio;
}

final authTokenHolderProvider = Provider<AuthTokenHolder>((ref) {
  return AuthTokenHolder();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenHolder = ref.watch(authTokenHolderProvider);
  return ApiClient(tokenHolder: tokenHolder);
});

/// Extracts a list from a DRF cursor-paginated or plain list response.
List<dynamic> extractList(dynamic data) {
  if (data is List) return data;
  if (data is Map<String, dynamic>) {
    final results = data['results'];
    if (results is List) return results;
  }
  return const [];
}
