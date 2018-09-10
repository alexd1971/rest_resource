class RestRequestMethod {
  static const RestRequestMethod get = RestRequestMethod._('GET');
  static const RestRequestMethod post = RestRequestMethod._('POST');
  static const RestRequestMethod put = RestRequestMethod._('PUT');
  static const RestRequestMethod patch = RestRequestMethod._('PATCH');
  static const RestRequestMethod delete = RestRequestMethod._('DELETE');

  final String _method;

  const RestRequestMethod._(String method) : _method = method;

  @override
  String toString() => _method;

  @override
  bool operator ==(other) {
    if (other is RestRequestMethod) return _method == other._method;
    return false;
  }

  @override
  int get hashCode => _method.hashCode;
}
