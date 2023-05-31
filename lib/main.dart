import 'package:flutter/material.dart';
import 'package:flutter_practice/scr/app.dart';
import 'package:flutter_practice/scr/riverpod_basics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(child: RiverpodBasicApp()),
  );
}
