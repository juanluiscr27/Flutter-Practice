import 'package:flutter/material.dart';
import 'package:flutter_practice/scr/state_management/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiverpodHome extends ConsumerWidget {
  const RiverpodHome({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer(
              builder: (context, ref, _) {
                return ref.watch(userProvider).when(
                  data: (String value) {
                    return Text(value);
                  },
                  error: (Object error, StackTrace stackTrace) {
                    return const Text('Error');
                  },
                  loading: () {
                    return const CircularProgressIndicator();
                  },
                );
              },
            ),
            const SizedBox(
              height: 100.0,
            ),
            Consumer(
              builder: (context, ref, _) {
                final count = ref.watch(counterController);
                return Text('Notifier: $count');
              },
            ),
            const SizedBox(
              height: 100.0,
            ),
            Consumer(
              builder: (context, ref, _) {
                return ref.watch(counterAsyncController).when(
                    data: (int value) {
                  return Text(value.toString());
                }, error: (Object error, StackTrace stackTrace) {
                  return const Text('Error');
                }, loading: () {
                  return const CircularProgressIndicator();
                });
              },
            ),
            const SizedBox(
              height: 100.0,
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(counterController.notifier).add();
                ref.read(counterAsyncController.notifier).add();
              },
              child: const Text('Add'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(counterController.notifier).subtract();
                ref.read(counterAsyncController.notifier).subtract();
              },
              child: const Text('Subtract'),
            ),
          ],
        ),
      ),
    );
  }
}
