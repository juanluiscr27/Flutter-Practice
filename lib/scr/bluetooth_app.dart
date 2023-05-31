import 'package:flutter/material.dart';

import 'neworking/bluetooth_home.dart';

class BluetoothApp extends StatelessWidget {
  const BluetoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod Basics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BluetoothHome(title: 'BLE Scan'),
    );
  }
}
