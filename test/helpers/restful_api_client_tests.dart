import 'dart:io';
import 'package:http/http.dart';
import 'package:test/test.dart';

import 'package:rest_resource/rest_resource.dart';

class RestfulApiClientTests {
  final Client _httpClient;

  RestfulApiClientTests(Client httpClient): _httpClient = httpClient;

  void run () {
    Uri apiUri;
    RestfulApiClient restfulApiClient;
    final requestParams = {
      'param1': 'value1',
      'param2': 'value2'
    };

    setUpAll(() async {
      final channel = spawnHybridUri('helpers/http_server.dart', stayAlive: true);
      final String hostPort = await channel.stream.first;
      apiUri = new Uri.http(hostPort, '/');
      restfulApiClient = new RestfulApiClient(
        apiUri: apiUri,
        httpClient: _httpClient
      );
      restfulApiClient.addHeaders({
        'X-Requested-With': 'XMLHttpRequest'
      });
    });

    test('get request', () async {
      final response = await restfulApiClient.get(
        resourcePath: '/resource',
        queryParameters: requestParams
      );
      expect(response.statusCode, HttpStatus.ok);
      expect(response.data, {
        'method': 'GET',
        'uri': apiUri.replace(
          path: '/resource',
          queryParameters: requestParams
        ).toString()
      });
    });

    test('post request', () async {
      final response = await restfulApiClient.post(
        resourcePath: '/resource',
        body: requestParams
      );
      expect(response.statusCode, HttpStatus.ok);
      expect(response.data, {
        'method': 'POST',
        'uri': apiUri.replace(
          path: '/resource',
        ).toString(),
        'body': requestParams
      });
    });

    test('put request', () async {
      final response = await restfulApiClient.put(
        resourcePath: '/resource',
        body: requestParams
      );
      expect(response.statusCode, HttpStatus.ok);
      expect(response.data, {
        'method': 'PUT',
        'uri': apiUri.replace(
          path: '/resource',
        ).toString(),
        'body': requestParams
      });
    });

    test('patch request', () async {
      final response = await restfulApiClient.patch(
        resourcePath: '/resource',
        body: requestParams
      );
      expect(response.statusCode, HttpStatus.ok);
      expect(response.data, {
        'method': 'PATCH',
        'uri': apiUri.replace(
          path: '/resource',
        ).toString(),
        'body': requestParams
      });
    });

    test('delete request', () async {
      final response = await restfulApiClient.delete(
        resourcePath: '/resource',
        queryParameters: requestParams
      );
      expect(response.statusCode, HttpStatus.ok);
      expect(response.data, {
        'method': 'DELETE',
        'uri': apiUri.replace(
          path: '/resource',
          queryParameters: requestParams
        ).toString()
      });
    });

    test('get request with unauthorized response', () async {
      final response = await restfulApiClient.get(
        resourcePath: '/unauthorized',
        queryParameters: requestParams
      );
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('get request with internal server error response', () async {
      final response = await restfulApiClient.get(
        resourcePath: '/servererror',
        queryParameters: requestParams
      );
      expect(response.statusCode, HttpStatus.internalServerError);
      expect(response.reasonPhrase, '${HttpStatus.internalServerError}-Internal Server Error');
    });

    test('post request with unauthorized response', () async {
      final response = await restfulApiClient.post(
        resourcePath: '/unauthorized',
        body: requestParams
      );
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('put request with unauthorized response', () async {
      final response = await restfulApiClient.put(
        resourcePath: '/unauthorized',
        body: requestParams
      );
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('patch request with unauthorized response', () async {
      final response = await restfulApiClient.patch(
        resourcePath: '/unauthorized',
        body: requestParams
      );
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('delete request with unauthorized response', () async {
      final response = await restfulApiClient.delete(
        resourcePath: '/unauthorized',
        queryParameters: requestParams
      );
      expect(response.statusCode, HttpStatus.unauthorized);
      expect(response.reasonPhrase, '${HttpStatus.unauthorized}-Unauthorized');
    });

    test('toEncodable()', () async {
      final encodable = new EncodableTest();
      final response = await restfulApiClient.post(
        resourcePath: '/echo-resource',
        body: {'test': encodable}
      );
      expect(response.statusCode, HttpStatus.ok);
      expect(response.data, {
        'test': {
          'id': 1234567890,
          'date': encodable.date.toUtc().toIso8601String()
        }
      });
    });
  }
}

class EncodableTest implements JsonEncodable {
  final id = ObjectId(1234567890);
  final date = DateTime.now();
  dynamic toJson() {
    return {
      'id': id,
      'date': date
    };
  }
}