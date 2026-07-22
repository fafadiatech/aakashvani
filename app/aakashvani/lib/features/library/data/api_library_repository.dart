import 'package:dio/dio.dart';
import 'package:aakashvani/core/api/api_client.dart';
import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/features/library/data/library_mappers.dart';
import 'package:aakashvani/features/library/domain/i_library_repository.dart';

class ApiLibraryRepository implements ILibraryRepository {
  ApiLibraryRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AudioClip>> getClips() async {
    final response = await _client.dio.get<dynamic>('/library/clips/');
    return extractList(response.data)
        .map((item) => audioClipFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AudioClip> addClip({
    required String title,
    required String category,
    required int durationMs,
    required ClipSource source,
    String? filePath,
  }) async {
    if (filePath == null || filePath.isEmpty) {
      throw Exception('A recorded audio file is required to upload.');
    }

    final form = FormData.fromMap({
      'title': title,
      'category': category,
      'duration_ms': durationMs,
      'source': source.name,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/library/clips/',
        data: form,
      );
      final data = response.data;
      if (data == null) {
        throw Exception('Empty response from server.');
      }
      return audioClipFromJson(data);
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  @override
  Future<void> deleteClip(String id) async {
    await _client.dio.delete<void>('/library/clips/$id/');
  }

  String _dioMessage(DioException e) {
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] != null) {
      return detail['detail'].toString();
    }
    if (detail is Map) {
      // Field errors from DRF
      final parts = <String>[];
      detail.forEach((key, value) {
        if (value is List) {
          parts.add('$key: ${value.join(', ')}');
        } else {
          parts.add('$key: $value');
        }
      });
      if (parts.isNotEmpty) return parts.join('; ');
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not reach the server. Check your network and API URL.';
    }
    return e.message ?? 'Upload failed.';
  }
}
