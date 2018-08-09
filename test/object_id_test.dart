import 'package:test/test.dart';

import 'package:rest_resource/src/object_id.dart';

class FirstObjectId extends ObjectId {
  FirstObjectId(id) : super(id);
}

class SecondObjectId extends ObjectId {
  SecondObjectId(id) : super(id);
}

void main() {
  test('equal ids', () {
    final id1 = FirstObjectId(1);
    final id2 = FirstObjectId(1);
    expect(id1 == id2, true);
  });

  test('not equal ids', () {
    final id1 = FirstObjectId(1);
    final id2 = SecondObjectId(1);
    expect(id1 == id2, false);
  });
}
