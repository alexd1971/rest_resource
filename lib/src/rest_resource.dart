import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';

import 'rest_request.dart';
import 'rest_response.dart';
import 'rest_request_method.dart';
import 'rest_client.dart';
import 'json_encodable.dart';
import 'object_id.dart';

/// Базовый класс для создания REST-ресурсов
///
/// Реализует все CRUD-методы для работы с ресурсами:
/// * `create` - создание нового объекта
/// * `read` - получение данных
/// * `update` - частичное изменение данных объекта
/// * `replace` - полная замена данных объекта
/// * `delete` - удаление объекта ресурса
///
/// Тип `T` определяет тип данных, которые хранит ресурс
abstract class RestResource<T extends JsonEncodable> {
  /// Путь к ресурсу на API-сервере
  final String resourcePath;

  /// API-клиент
  @protected
  final RestClient apiClient;

  /// Создает новый ресурс
  RestResource({@required this.resourcePath, @required this.apiClient})
      : assert(resourcePath != null),
        assert(apiClient != null);

  /// Создает новый объект ресурса
  ///
  /// Возвращает [Future] с созданным объектом
  Future<T> create(T obj, {Map<String, String> headers = const {}}) async {
    if (!(obj is JsonEncodable))
      throw ArgumentError.value(
          obj, 'obj', 'Creating object must be JsonEncodable');
    final response = await apiClient.send(RestRequest(
        method: RestRequestMethod.post,
        resourcePath: resourcePath,
        headers: headers,
        body: obj.toJson()));
    return processResponse(response);
  }

  /// Читает данные ресурса
  ///
  /// `obj` может быть:
  ///
  /// * идентификатором объекта ресурса (наследник [ObjectId])
  /// * [Map], содержащий параметры запроса
  ///
  /// Если методу передается идентификатор объекта, то возвращается [Future] с указанным объектом.
  ///
  /// Если методу передаются параметры запроса, то возвращается [Future] со списком объектов
  /// соответствующих запросу.
  Future read(dynamic obj, {Map<String, String> headers = const {}}) async {
    String path;
    Map<String, String> queryParameters;

    if (obj is ObjectId) {
      path = '$resourcePath/$obj';
    } else if (obj is Map) {
      path = resourcePath;
      queryParameters = obj;
    } else {
      throw (ArgumentError.value(obj, 'obj',
          'Read criteria must be an ObjectId or Map of query parameters'));
    }
    final response = await apiClient.send(RestRequest(
        method: RestRequestMethod.get,
        resourcePath: path,
        queryParameters: queryParameters,
        headers: headers));
    return processResponse(response);
  }

  /// Частично обновляет данные объекта
  ///
  /// Изменению подвергаются только явно указанные параметры объекта.
  /// параметры, имеющие значение `null` и пустые параметры не изменяются
  ///
  /// Возвращает [Future] с измененным объектом
  Future<T> update(T obj, {Map<String, String> headers = const {}}) async {
    if (!(obj is JsonEncodable))
      throw ArgumentError.value(
          obj, 'obj', 'Updating object must be JsonEncodable');
    final response = await apiClient.send(RestRequest(
        method: RestRequestMethod.patch,
        resourcePath: resourcePath,
        headers: headers,
        body: obj.toJson()));
    return processResponse(response);
  }

  /// Полностью обновляет данные
  ///
  /// Данные объекта полностью заменяются данными передаваемого объекта.
  /// Если какие-то параметры имеют значение `null` или пустые, то они удаляются
  ///
  /// Возвращает [Future] с измененным объектом
  Future<T> replace(T obj, {Map<String, String> headers = const {}}) async {
    if (!(obj is JsonEncodable))
      throw ArgumentError.value(
          obj, 'obj', 'Replacing object must be JsonEncodable');
    final response = await apiClient.send(RestRequest(
        method: RestRequestMethod.put,
        resourcePath: resourcePath,
        headers: headers,
        body: obj.toJson()));
    return processResponse(response);
  }

  /// Удаляет объект
  ///
  /// `obj` может быть:
  ///
  /// * идентификатором объекта ресурса (наследник [ObjectId])
  /// * [Map], содержащий параметры запроса
  ///
  /// Если методу передается идентификатор объекта, то удаляется указанный объект и
  /// возвращается [Future] с этим объектом.
  ///
  /// Если методу передаются параметры запроса, то удаляются все объекты, удовлетворяющие запросу и
  /// возвращается [Future] со списком удаленных объектов.
  Future delete(dynamic obj, {Map<String, String> headers = const {}}) async {
    String path;
    Map<String, String> queryParameters;

    if (obj is ObjectId) {
      path = '$resourcePath/$obj';
    } else if (obj is Map) {
      path = resourcePath;
      queryParameters = obj;
    } else {
      throw (ArgumentError.value(obj, 'obj',
          'Delete criteria must be an ObjectId or Map of query parameters'));
    }
    final response = await apiClient.send(RestRequest(
        method: RestRequestMethod.delete,
        resourcePath: path,
        queryParameters: queryParameters,
        headers: headers));
    return processResponse(response);
  }

  @protected
  dynamic processResponse(RestResponse response) {
    if (response.statusCode != HttpStatus.ok) {
      throw (HttpException(response.reasonPhrase));
    }
    if (response.body is Map) {
      return createObject(response.body);
    } else if (response.body is List) {
      return response.body.map((json) => createObject(json)).toList();
    } else {
      throw FormatException('Invalid http response format');
    }
  }

  /// Создает объект типа `T`
  ///
  /// Абстрактный метод, реализующий паттерн "Фабричный метод".
  ///
  /// Метод должен быть реализован в классах наследниках.
  @protected
  T createObject(Map<String, dynamic> json);
}
