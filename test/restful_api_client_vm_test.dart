@Timeout(const Duration(seconds: 10))
@TestOn('vm')

import 'package:test/test.dart';
import 'package:http/http.dart';

import 'helpers/restful_api_client_tests.dart';

void main() {
  RestfulApiClientTests(IOClient()).run();
}
