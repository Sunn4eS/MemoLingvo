import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: 'http://dabilone123-001-site1.ltempurl.com/api', 
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Пользователя мы отправляем по одному, тут оставляем Map
  // В файле: lib/core/network/api_client.dart

  // УБЕРИ старый метод pushUser и вставь эти:

  // В файле: lib/core/network/api_client.dart

  // Обнови методы loginUser и registerUser, добавив параметр uid
  Future<Map<String, dynamic>?> registerUser(String email, String uid) async {
    try {
      final response = await _dio.post('/Auth/register', data: {
        'email': email,
        'passwordHash': uid // Передаем UID из Firebase как пароль!
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      _logError('User Register', e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String uid) async {
    try {
      final response = await _dio.post('/Auth/login', data: {
        'email': email,
        'passwordHash': uid // Передаем UID из Firebase как пароль!
      });
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      _logError('User Login', e);
    }
    return null;
  }

  // А ЗДЕСЬ МЕНЯЕМ НА List<Map<String, dynamic>>
  Future<bool> pushDeck(List<Map<String, dynamic>> data) async {
    try {
      final response = await _dio.post('/Decks/sync', data: data); 
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      _logError('Deck', e);
      return false;
    }
  }

  // МЕНЯЕМ НА List
  Future<bool> pushCard(List<Map<String, dynamic>> data) async {
    try {
      final response = await _dio.post('/Cards/sync', data: data); 
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      _logError('Card', e);
      return false;
    }
  }

  // МЕНЯЕМ НА List
  Future<bool> pushProgress(List<Map<String, dynamic>> data) async {
    try {
      final response = await _dio.post('/Progress/sync', data: data); 
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      _logError('Progress', e);
      return false;
    }
  }

  // --- МЕТОДЫ PULL (ПОЛУЧЕНИЕ С СЕРВЕРА) ---

  Future<List<dynamic>> getDecks(String userId) async {
    try {
      final response = await _dio.get('/Decks/$userId');
      return response.data as List<dynamic>; // Сервер вернет JSON-массив
    } catch (e) {
      print('Ошибка при скачивании колод: $e');
      return [];
    }
  }

  Future<List<dynamic>> getCards(String userId) async {
    try {
      final response = await _dio.get('/Cards/sync/$userId');
      return response.data as List<dynamic>;
    } catch (e) {
      print('Ошибка при скачивании карточек: $e');
      return [];
    }
  }

  Future<List<dynamic>> getProgress(String userId) async {
    try {
      final response = await _dio.get('/Progress/$userId');
      return response.data as List<dynamic>;
    } catch (e) {
      if (e is DioException) {
        print('❌ Ошибка бэкенда при скачивании прогресса [${e.response?.statusCode}]:');
        print('Ответ сервера: ${e.response?.data}'); // <-- Это покажет, где именно упал C#
      } else {
        print('❌ Неизвестная ошибка: $e');
      }
      return [];
    }
  }

  void _logError(String model, dynamic e) {
    if (e is DioException) {
      print('❌ Ошибка ApiClient ($model) [${e.response?.statusCode}]:');
      print('Текст ответа от сервера: ${e.response?.data}'); 
    } else {
      print('❌ Ошибка ApiClient ($model): $e');
    }
  }
}