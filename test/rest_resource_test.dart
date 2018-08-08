@TestOn('vm')
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:http/http.dart';

import 'package:rest_resource/rest_resource.dart';

class TestResource extends RestResource<TestResourceObject> {

  TestResource({
    @required RestfulApiClient apiClient
  }): super(
    resourcePath: 'echo-resource',
    apiClient: apiClient
  );

  TestResourceObject createObject(Map<String,dynamic> json) => TestResourceObject.fromJson(json);
}

class TestResourceObject implements JsonEncodable {
  Map<String,dynamic> _data;
  
  TestResourceObject.fromJson(Map<String,dynamic> json): _data = json;

  Map<String,dynamic> toJson() => _data;

  @override
  bool operator== (other) {
    if (other is TestResourceObject) {
      return other._data.keys.every((key) => _data.containsKey(key)) &&
        _data.keys.every((key) => _data[key] == other._data[key]);
    }
    return false;
  }

  @override
  int get hashCode => _data.hashCode;
}

class TestResourceObjectId extends ObjectId {
  TestResourceObjectId(id): super(id);
}

void main() {
  TestResource testResource;
  final newObject = new TestResourceObject.fromJson({'test': 'create object'});

  setUpAll(() async {
    final channel = spawnHybridUri('helpers/http_server.dart', stayAlive: true);
    final String hostPort = await channel.stream.first;
    final apiUri = new Uri.http(hostPort, '/');
    final apiClient = new RestfulApiClient(
      apiUri: apiUri,
      httpClient: IOClient()
    );
    apiClient.addHeaders({
      'X-Requested-With': 'XMLHttpRequest'
    });
    testResource = new TestResource(apiClient: apiClient);
  });

  test('create object', () async {
    expect(testResource.create(newObject), completion(newObject));
  });

  test('update object', () async {
    expect(testResource.update(newObject), completion(newObject));
  });

  test('replace object', () async {
    expect(testResource.replace(newObject), completion(newObject));
  });

  test('get object', () async {
    expect(
      testResource.read(new TestResourceObjectId(1)),
      completion(new TestResourceObject.fromJson({
        'id': 1
      }))
    );
  });

  test('get objects by query', () async {
    expect(
      testResource.read({'all': 'true'}),
      completion(containsAll([
        new TestResourceObject.fromJson({'id': 1}),
        new TestResourceObject.fromJson({'id': 2})
      ]))
    );
  });

  test('delete object', () async {
    expect(
      testResource.delete(new TestResourceObjectId(1)),
      completion(new TestResourceObject.fromJson({
        'id': 1
      }))
    );
  });

  test('delete objects by query', () async {
    expect(
      testResource.delete({'all': 'true'}),
      completion(containsAll([
        new TestResourceObject.fromJson({'id': 1}),
        new TestResourceObject.fromJson({'id': 2})
      ]))
    );
  });
}