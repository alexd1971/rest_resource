/// Ответ API-сервера
class RestResponse {
  /// Http-статус ответа
  final int statusCode;

  /// Заголовки ответа
  Map<String, String> _headers;
  Map<String, String> get headers => _headers;

  /// Сообщение сервера
  final String reasonPhrase;

  /// Тело ответа
  final body;

  RestResponse(
      {this.statusCode,
      this.reasonPhrase,
      Map<String, String> headers,
      this.body}) {
    _headers = Map.unmodifiable(headers);
  }

  RestResponse change(
          {int statusCode,
          String reasonPhrase,
          Map<String, String> headers,
          body}) =>
      RestResponse(
          statusCode: statusCode == null ? this.statusCode : statusCode,
          reasonPhrase: reasonPhrase == null ? this.reasonPhrase : reasonPhrase,
          headers: headers == null ? this.headers : headers,
          body: body == null ? this.body : body);
}
