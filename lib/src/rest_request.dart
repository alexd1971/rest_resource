import 'rest_request_method.dart';

class RestRequest {
  final RestRequestMethod method;
  final String resourcePath;

  Map<String, String> _queryParameters;
  Map<String, String> get queryParameters => _queryParameters;

  Map<String, String> _headers;
  Map<String, String> get headers => _headers;

  final dynamic body;

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
