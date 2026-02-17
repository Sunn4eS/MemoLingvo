import 'package:dio/dio.dart';

class DictionaryApi {
  final Dio dio;

  DictionaryApi({required this.dio});

  Future<String?> fetchDefinition(String word) async {
    try {
      final response = await dio.get('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
      final data = response.data as List;

      if (data.isNotEmpty) {
        return data[0]['meanings'][0]['definitions'][0]['definition'];

      }

    } catch (e) {
      return null;
    }
    return null;
  }
}