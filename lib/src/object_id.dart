import 'package:quiver/core.dart';

import 'json_encodable.dart';

/// Идентификтор ресурса
///
/// Инкапсулирует идентификатор любого типа. Позволяет выполнять сравнение идентификаторов.
///
/// Предпочтительно для каждого ресурса создавать новый класс на основе [ObjectId].
///
/// Пример:
///
///     class UserId extends ObjectId {
///       UserId(id): super(id);
///     }
class ObjectId implements JsonEncodable {
  final _id;

  ObjectId(id) : _id = id;

  /// Исходное значение идентификатора
  dynamic get value => _id;

  dynamic toJson() {
    if (_id is num || _id is String) {
      return _id;
    }
    return _id.toString();
  }

  @override
  bool operator ==(other) {
    if (other is ObjectId) {
      return this.runtimeType == other.runtimeType && _id == other._id;
    }
    return false;
  }

  @override
  int get hashCode => hash2(this.runtimeType, _id);

  @override
  String toString() => _id.toString();
}
