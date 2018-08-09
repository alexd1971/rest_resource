import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_response.dart';
import 'json_encodable.dart';

/// Restful API клиент
///
/// Реализует базовые методы Restful API
class RestfulApiClient {
  final http.Client _httpClient;
  final Uri _apiUri;
  final _headers = <String, String>{};

  /// Создает новый RestfulApiClient
  ///
  /// `apiUri` - адрес API-сервера
  /// `httpClient` - используемый http-клиент:
  ///
  /// * [BrowserClient] - при использовании в браузере
  /// * [IOClient] - при использовании во Flutter или VM
  RestfulApiClient({Uri apiUri, http.Client httpClient})
      : _httpClient = httpClient,
        _apiUri = apiUri;

  /// Выполняет GET-запрос к API-серверу. Получение данных ресурса.
  ///
  /// `resourcePath` - путь к ресурсу на API-сервере
  ///
  /// `queryParameters` - параметры запроса
  ///
  /// Возвращает [Future] с [ApiResponse]
  Future<ApiResponse> get(
      {String resourcePath, Map<String, String> queryParameters}) async {
    final response = await _httpClient.get(
        _apiUri.replace(path: resourcePath, queryParameters: queryParameters),
        headers: _headers);

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет POST-запрос к API-серверу. Создание нового объекта ресурса.
  ///
  /// `resourcePath` - путь к ресурсу на API-сервере.
  ///
  /// `body` - тело запроса. В теле запроса передаются данные создаваемого объекта
  ///
  /// `Content-Type` запроса всегда `application/json`. Поэтому тело запроса должно преобразовываться
  /// в JSON-строку с помощью `json.decode()`
  ///
  /// Все объекты `body` могут быть:
  ///
  /// * простыми данными числового и строкового типа
  /// * объектами типа [DateTime]
  /// * объектами, реализующими интерфейс [JsonEncodable]
  /// * списками ([List]) перечисленных выше типов
  ///
  /// Возвращает [Future] с [ApiResponse]
  Future<ApiResponse> post(
      {String resourcePath, Map<String, dynamic> body}) async {
    var requestBody;
    requestBody = json.encode(body, toEncodable: _toEncodable);

    final response = await _httpClient.post(_apiUri.replace(path: resourcePath),
        headers: _headers, body: requestBody);

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет PUT-запрос к API-серверу. Обновление (замена) объекта ресурса.
  ///
  /// `resourcePath` - путь к ресурсу на API-сервере.
  ///
  /// `body` - тело запроса. В теле запроса передаются данные объекта.
  ///
  /// `Content-Type` запроса всегда `application/json`. Поэтому тело запроса должно преобразовываться
  /// в JSON-строку с помощью `json.decode()`
  ///
  /// Все объекты `body` могут быть:
  ///
  /// * простыми данными числового и строкового типа
  /// * объектами типа [DateTime]
  /// * объектами, реализующими интерфейс [JsonEncodable]
  /// * списками ([List]) перечисленных выше типов
  ///
  /// Возвращает [Future] с [ApiResponse]
  Future<ApiResponse> put(
      {String resourcePath, Map<String, dynamic> body}) async {
    final response = await _httpClient.put(_apiUri.replace(path: resourcePath),
        headers: _headers, body: json.encode(body, toEncodable: _toEncodable));

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет PATCH-запрос к API-серверу. Частичное обновление данных объекта
  ///
  /// `resourcePath` - путь к ресурсу на API-сервере.
  ///
  /// `body` - тело запроса. Тело запроса содержит объект с обновляемыми данными
  ///
  /// `Content-Type` запроса всегда `application/json`. Поэтому тело запроса должно преобразовываться
  /// в JSON-строку с помощью `json.decode()`
  ///
  /// Все объекты `body` могут быть:
  ///
  /// * простыми данными числового и строкового типа
  /// * объектами типа [DateTime]
  /// * объектами, реализующими интерфейс [JsonEncodable]
  /// * списками ([List]) перечисленных выше типов
  ///
  /// Возвращает [Future] с [ApiResponse]
  Future<ApiResponse> patch(
      {String resourcePath, Map<String, dynamic> body}) async {
    final response = await _httpClient.patch(
        _apiUri.replace(path: resourcePath),
        headers: _headers,
        body: json.encode(body, toEncodable: _toEncodable));

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет DELETE-запрос к API-серверу
  ///
  /// `resourcePath` - путь к ресурсу на API-сервере
  ///
  /// `queryParameters` - параметры запроса
  ///
  /// Возвращает [Future] с [ApiResponse]
  Future<ApiResponse> delete(
      {String resourcePath, Map<String, String> queryParameters}) async {
    final response = await _httpClient.delete(
        _apiUri.replace(path: resourcePath, queryParameters: queryParameters),
        headers: _headers);

    return ApiResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Добавляет http-заголовок
  ///
  /// Добавленный заголовок будет отправляться при каждом запросе к API-серверу
  void addHeaders(Map<String, String> headers) {
    _headers.addAll(headers);
  }

  /// Удаляет заголовок
  void removeHeader(String header) {
    _headers.remove(header);
  }

  /// Приводит `value` к формату, поддающемуся кодированию в JSON-строку.
  ///
  /// Метод вызывается только в случае, если `json.encode` не может самостоятельно
  /// закодировать `value` в JSON-строку.
  ///
  /// `value` должно быть либо [DateTime], либо реализовывать интерфейс [JsonEncodable].
  /// В противном случае выбрасывается [FormatException]
  dynamic _toEncodable(value) {
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    } else if (value is JsonEncodable) {
      return value.toJson();
    } else {
      throw FormatException('Cannot encode to JSON value: $value');
    }
  }
}
