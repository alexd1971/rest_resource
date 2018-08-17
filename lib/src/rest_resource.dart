import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';

import 'api_response.dart';
import 'restful_api_client.dart';
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
  Future<T> create(T obj) async {
    final response =
        await apiClient.post(resourcePath: resourcePath, body: obj.toJson());
    return _processResponse(response);
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
  Future read(dynamic obj) async {
    String path;
    Map<String, String> queryParameters;

    if (obj is ObjectId) {
      path = '$resourcePath/$obj';
    } else if (obj is Map) {
      path = resourcePath;
      queryParameters = obj;
    }
    final response = await apiClient.get(
        resourcePath: path, queryParameters: queryParameters);
    return _processResponse(response);
  }

  /// Частично обновляет данные объекта
  ///
  /// Изменению подвергаются только явно указанные параметры объекта.
  /// параметры, имеющие значение `null` и пустые параметры не изменяются
  ///
  /// Возвращает [Future] с измененным объектом
  Future<T> update(T obj) async {
    final response =
        await apiClient.patch(resourcePath: resourcePath, body: obj.toJson());
    return _processResponse(response);
  }

  /// Полностью обновляет данные
  ///
  /// Данные объекта полностью заменяются данными передаваемого объекта.
  /// Если какие-то параметры имеют значение `null` или пустые, то они удаляются
  ///
  /// Возвращает [Future] с измененным объектом
  Future<T> replace(T obj) async {
    final response =
        await apiClient.put(resourcePath: resourcePath, body: obj.toJson());
    return _processResponse(response);
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
  Future delete(dynamic obj) async {
    String path;
    Map<String, String> queryParameters;

    if (obj is ObjectId) {
      path = '$resourcePath/$obj';
    } else if (obj is Map) {
      path = resourcePath;
      queryParameters = obj;
    }
    final response = await apiClient.delete(
        resourcePath: path, queryParameters: queryParameters);
    return _processResponse(response);
  }

  dynamic _processResponse(ApiResponse response) {
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
