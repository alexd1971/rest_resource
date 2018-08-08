class ApiResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String reasonPhrase;
  final data;

  ApiResponse({
    this.statusCode,
    this.headers,
    this.reasonPhrase,
    this.data
  });
}