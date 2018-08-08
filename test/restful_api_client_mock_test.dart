@Skip('Это просто пример теста через Mock. Может пригодится')
import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart';

import 'package:rest_resource/rest_resource.dart';

final apiUri = Uri.http('localhost', '/resource');
final headers = <String,String> {
  'X-Requested-With': 'XMLHttpRequest'
};
class MockClient extends Mock implements Client {}

main() {
  test('mock get', () async {
    final mockClient = new MockClient();
    when(mockClient.get(apiUri, headers: headers)).thenAnswer((_) => new Future.value(Response('GET: $apiUri', HttpStatus.ok)));
    final restfulApiClient = RestfulApiClient(
      apiUri: apiUri,
      httpClient: mockClient
    );
    expect(restfulApiClient.get(), completion('GET: $apiUri'));
  });
}