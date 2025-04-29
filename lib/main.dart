import 'package:flutter/material.dart';
import 'wifi_status_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'My WiFi',
      home: const WifiStatusScreen(title: 'WiFi Status Checker'),
    );
  }
}