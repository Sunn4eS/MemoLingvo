import 'package:dio/dio.dart';

class DictionaryApi {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, dynamic>> fetchWordInfo(String word) async {
    try {
      final response = await _dio.get(
        'https://api.dictionaryapi.dev/api/v2/entries/en/$word',
      );

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        return response.data[0];
      } else {
        throw Exception('API вернул неожиданный ответ');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }
}
