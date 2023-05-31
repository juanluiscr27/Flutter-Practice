import 'package:flutter_practice/scr/state_management/fake_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides states for Consumer
final userProvider = FutureProvider<String>(
  (ref) async => ref.read(databaseProvider).getUserData(),
);

// State Notifier
final counterController = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void add() {
    state++;
  }

  void subtract() {
    state--;
  }
}

// Future Provider
final counterAsyncController =
    StateNotifierProvider<CounterAsyncNotifier, AsyncValue<int>>(
  (ref) => CounterAsyncNotifier(ref),
);

class CounterAsyncNotifier extends StateNotifier<AsyncValue<int>> {
  CounterAsyncNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  final Ref ref;

  void _init() async {
    ref.read(databaseProvider).initDatabase;
    state = const AsyncData(0);
  }

  void add() async {
    state = const AsyncLoading();
    int count = await ref.read(databaseProvider).increment();
    state = AsyncData(count);
  }

  void subtract() async {
    state = const AsyncLoading();
    int count = await ref.read(databaseProvider).decrement();
    state = AsyncData(count);
  }
}
