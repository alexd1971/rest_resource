/// Ответ API-сервера
class ApiResponse {
  /// Http-статус ответа
  final int statusCode;

  /// Заголовки ответа
  final Map<String, String> headers;

  /// Сообщение сервера
  final String reasonPhrase;

  /// Тело ответа
  final body;

  ApiResponse({this.statusCode, this.headers, this.reasonPhrase, this.body});
}
