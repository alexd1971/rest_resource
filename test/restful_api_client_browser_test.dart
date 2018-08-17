@Timeout(const Duration(seconds: 10))
@TestOn('browser')

import 'package:test/test.dart';
import 'package:http/browser_client.dart';

import 'helpers/restful_api_client_tests.dart';

void main() {
  RestClientTests(BrowserClient()).run();
}
