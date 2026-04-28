import 'package:dio/dio.dart';

class DictionaryApi {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> fetchWordInfo(String word) async {
    try {
      final response = await _dio.get('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
      
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
        return response.data[0];
      }
    } catch (e) {
      print('Ошибка получения данных из Dictionary API: $e');
    }
    return null;
  }
}