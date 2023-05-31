import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<FakeDatabase>((ref) => FakeDatabase());

class FakeDatabase {
  late int fakeDatabase;
  FakeDatabase() {
    initDatabase();
  }

  Future<String> getUserData() {
    return Future.delayed(
      const Duration(seconds: 2),
      () => "Juan",
    );
  }

  Future<void> initDatabase() async {
    fakeDatabase = 0;
  }

  Future<int> increment() async {
    return Future.delayed(
      const Duration(seconds: 2),
      () => fakeDatabase++,
    );
  }

  Future<int> decrement() async {
    return Future.delayed(
      const Duration(seconds: 2),
      () => fakeDatabase--,
    );
  }
}
