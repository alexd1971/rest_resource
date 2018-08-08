import 'dart:async';
import 'dart:io';

import 'package:http/browser_client.dart';

import 'package:rest_resource/rest_resource.dart';

/// Идентификатор пользователя
class UserId extends ObjectId {
  UserId(id): super(id);
}

/// Пользователь
class User implements JsonEncodable {
  
  UserId _id;
  /// Идентификтор
  UserId get id => _id;
  
  /// Имя пользователя
  String userName;

  /// Фамилия
  String lastName;

  /// Имя
  String firstName;

  /// Полное имя
  String get fullName => '$firstName $lastName';

  /// Дата рождения
  DateTime birthDate;

  /// Создает пользователя
  User({
    this.userName,
    this.lastName,
    this.firstName,
    this.birthDate
  });

  /// Создает пользователя из JSON-данных
  User.fromJson(Map<String,dynamic> json):
    _id = json['id'],
    userName = json['username'],
    lastName = json['lastname'],
    firstName = json['firstname'],
    birthDate = DateTime.parse(json['birth_date']);

  dynamic toJson() {
    Map<String,dynamic> result = {
      'id': _id,
      'username': userName,
      'lastname': lastName,
      'firstname': firstName,
      'birth_date': birthDate
    };
    // Перед возвратом результата полезно удалить все пустые атрибуты:
    // * уменьшается трафик
    // * не захламляется база
    // * легко реализуется частичное обновление данных объекта
    return result..removeWhere((key, value) => value == null);
  }
}

/// Ресурс Users
/// 
/// Оперирует с объектами [User].
/// В дополнение к стандартным CRUD-методам реализует методы:
/// * `login` - вход в систему
/// * `logout` - выход из системы
class Users extends RestResource<User> {
  Users(RestfulApiClient apiClient): super(
    resourcePath: '/users',
    apiClient: apiClient
  );

  User createObject(Map<String,dynamic> json) => User.fromJson(json);

  /// Осуществляет вход в систему
  Future<User> login(String username, String password) async {
    final response = await apiClient.post(
      resourcePath: '$resourcePath/login',
      body: {
        'username': username,
        'password': password
      }
    );
    if (response.statusCode != HttpStatus.ok) {
      throw (response.reasonPhrase);
    }
    return User.fromJson(response.data);
  }

  /// Осуществляет выход из системы
  Future logout() async {
    final response = await apiClient.post(
      resourcePath: '$resourcePath/logout'
    );
    if (response.statusCode != HttpStatus.ok) {
      throw (response.reasonPhrase);
    }
  }
}

main() async {
  final apiClient = new RestfulApiClient(
    apiUri: Uri.http('api.examle.com', '/'),
    httpClient: new BrowserClient()
  );
  apiClient.addHeaders({
     'X-Requested-With': 'XMLHttpRequest'
  });

  final users = new Users(apiClient);
  
  User currentUser;
  try {
    currentUser = await users.login('username', 'password');
  } catch (e) {
    // Здесь обрабатываем неудачный логин. Причина в e.message.
  }
  print('Пользователь ${currentUser.fullName} успешно аутентифицировался');

  final newUser = User(
    userName: 'newuser',
    firstName: 'Bob',
    lastName: 'Martin',
    birthDate: DateTime(1952)
  );
  
  User createdUser;
  try {
    createdUser = await users.create(newUser);
  } catch (e) {
    // Обработка ошибки создания пользователя
  }
  
  print('Пользователь ${createdUser.fullName} успешно создан');

  List<User> bobs;
  try {
    bobs = await users.read({'firstname': 'Bob'});
  } catch (e) {
    // Обработка ошибки получения данных
  }
  bobs.forEach((bob) {
    // Выполняем что-то для пользователей с именем Bob
    print('${bob.fullName} - ${bob.birthDate}');
  });
}