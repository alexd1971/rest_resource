import 'rest_request_method.dart';

/// Запрос к REST-ресурсу
class RestRequest {
  /// Метод
  /// 
  /// [RestRequest] поддерживает методы:
  /// * GET     получение данных
  /// * POST    создание новых объектов
  /// * PUT     замена данных объекта
  /// * PATCH   модификация данных объекта
  /// * DELETE  удаление объекта 
  final RestRequestMethod method;

  /// Путь к ресурсу
  final String resourcePath;

  Map<String, String> _queryParameters;

  /// Параметры запроса
  Map<String, String> get queryParameters => _queryParameters;

  Map<String, String> _headers;

  /// Заголовки запроса
  Map<String, String> get headers => _headers;

  /// Тело запроса
  final dynamic body;

  /// Создает новый запрос
  RestRequest(
      {this.method = RestRequestMethod.get,
      this.resourcePath = '/',
      Map<String, String> queryParameters,
      Map<String, String> headers = const {},
      this.body}) {
    _headers = Map.unmodifiable(headers);
    _queryParameters =
        queryParameters != null ? Map.unmodifiable(queryParameters) : null;
  }

  /// Изменяет данные запроса
  /// 
  /// Возвращает новый запрос, в котором данные изменены на указанные
  RestRequest change(
          {RestRequestMethod method,
          String resourcePath,
          Map<String, String> queryParameters,
          Map<String, String> headers,
          dynamic body}) =>
      RestRequest(
          method: method == null ? this.method : method,
          resourcePath: resourcePath == null ? this.resourcePath : resourcePath,
          queryParameters:
              queryParameters == null ? _queryParameters : queryParameters,
          headers: headers == null ? _headers : headers,
          body: body == null ? this.body : body);
}
