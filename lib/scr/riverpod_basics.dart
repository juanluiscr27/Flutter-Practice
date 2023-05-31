import 'package:flutter/material.dart';
import 'package:flutter_practice/scr/state_management/riverpod_home.dart';

class RiverpodBasicApp extends StatelessWidget {
  const RiverpodBasicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod Basics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: RiverpodHome(title: 'Riverpod Basics'),
    );
  }
}
