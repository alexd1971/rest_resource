/// Поддержка работы с REST-ресурсами на стороне клиента.
///
/// ## Назначение
///
/// Библиотека предназначена для создания REST-клиентов (поддерживаются web- и mobile-клиенты)
///
/// ## Структура
///
/// В основе библиотеки лежит класс `RestResource`, который для общения с API-сервером использует `RestfulApiClient`. Объекты, с которыми работает `RestResource` должны реализовывать интерфейс `JsonEncodable`
///
/// `RestResource` изначально поддерживает стандартные методы (CRUD) работы с REST-ресурсами:
/// * `create` - создание объекта
/// * `read` - получение объекта/списка объектов
/// * `update` - частичное обновление данных объекта
/// * `replace` - полная замена данных объекта
/// * `delete` - удаление объекта
///
/// При наследовании ресурсы можно дополнять другими необходимыми методами.
///
/// ## Примеры использования
///
/// Конкретные варианты использования можно посмотреть в [примерах](https://github.com/alexd1971/rest_resource/blob/master/example/rest_resource_example.dart), а также кое что можно почерпнуть из тестов.
library rest_resource;

export 'src/api_response.dart';
export 'src/json_encodable.dart';
export 'src/object_id.dart';
export 'src/restful_api_client.dart';
export 'src/rest_resource.dart';
