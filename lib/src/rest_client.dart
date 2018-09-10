import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'rest_request.dart';
import 'rest_request_method.dart';
import 'rest_response.dart';
import 'json_encodable.dart';

typedef RestRequest OnBeforeRequest(RestRequest request);
typedef RestResponse OnAfterResponse(RestResponse response);

/// Restful API клиент
///
/// Реализует базовые методы Restful API
class RestClient {
  final http.Client _httpClient;
  final Uri _apiUri;
  final OnBeforeRequest _onBeforeRequest;
  final OnAfterResponse _onAfterResponse;

  /// Создает новый RestClient
  ///
  /// [apiUri] - адрес API-сервера
  /// [httpClient] - используемый http-клиент:
  ///
  /// * [BrowserClient] - при использовании в браузере
  /// * [IOClient] - при использовании во Flutter или VM
  ///
  /// [onBeforeRequest] callback, принимающий на вход [RestRequest] и возвращающий [RestRequest].
  /// Можно применять в случае необходимости модифицировать исходный запрос.
  ///
  /// [onAfterResponse] callback, принимающий на вход [RestResponse] и возвращающий [RestResponse].
  /// Можно применять в случае необходимости получать дополнительные данные ответа.
  RestClient(Uri apiUri, http.Client httpClient,
      {OnBeforeRequest onBeforeRequest, OnAfterResponse onAfterResponse})
      : _httpClient = httpClient,
        _apiUri = apiUri,
        _onBeforeRequest = onBeforeRequest,
        _onAfterResponse = onAfterResponse {
    if (apiUri == null) throw (ArgumentError.notNull('apiUri'));
    if (httpClient == null) throw (ArgumentError.notNull('httpClient'));
  }

  /// Выполняет запрос к API-серверу.
  ///
  /// `resourcePath` - путь к ресурсу на API-сервере
  ///
  /// `queryParameters` - параметры запроса
  ///
  /// `headers` - заголовки запроса
  ///
  /// `body` - тело запроса.
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
  /// При GET- и DELETE-запросах тело запроса игнорируется
  ///
  /// Возвращает [Future] с [RestResponse]
  Future<RestResponse> send(RestRequest request) async {
    if (_onBeforeRequest != null) request = _onBeforeRequest(request);

    var requestUri = _apiUri.replace(
        path: normalize(join(_apiUri.path, request.resourcePath)),
        queryParameters: request.queryParameters);

    RestResponse restResponse;

    if (request.method == RestRequestMethod.get) {
      restResponse = await _get(requestUri, request.headers);
    } else if (request.method == RestRequestMethod.post) {
      restResponse = await _post(requestUri, request.body, request.headers);
    } else if (request.method == RestRequestMethod.put) {
      restResponse = await _put(requestUri, request.body, request.headers);
    } else if (request.method == RestRequestMethod.patch) {
      restResponse = await _patch(requestUri, request.body, request.headers);
    } else if (request.method == RestRequestMethod.delete) {
      restResponse = await _delete(requestUri, request.headers);
    } else {
      throw (ArgumentError(
          'Unsupported RestRequest method: ${request.method}'));
    }

    if (_onAfterResponse != null) restResponse = _onAfterResponse(restResponse);

    return restResponse;
  }

  /// Выполняет GET-запрос
  Future<RestResponse> _get(Uri requestUri,
      [Map<String, String> headers = const {}]) async {
    http.Response response =
        await _httpClient.get(requestUri, headers: headers);
    return RestResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет POST-запрос к API-серверу.
  Future<RestResponse> _post(Uri requestUri, dynamic body,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.post(requestUri,
        headers: headers, body: json.encode(body, toEncodable: _toEncodable));

    return RestResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет PUT-запрос.
  Future<RestResponse> _put(Uri requestUri, dynamic body,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.put(requestUri,
        headers: headers, body: json.encode(body, toEncodable: _toEncodable));

    return RestResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет PATCH-запрос.
  Future<RestResponse> _patch(Uri requestUri, dynamic body,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.patch(requestUri,
        headers: headers, body: json.encode(body, toEncodable: _toEncodable));

    return RestResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
  }

  /// Выполняет DELETE-запрос.
  Future<RestResponse> _delete(Uri requestUri,
      [Map<String, String> headers = const {}]) async {
    final response = await _httpClient.delete(requestUri, headers: headers);

    return RestResponse(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        body: response.body.isNotEmpty ? json.decode(response.body) : '');
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
