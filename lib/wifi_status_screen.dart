import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../wifi_service.dart';
import '../permission_service.dart';
import '../wifi_status_widgets.dart';

class WifiStatusScreen extends StatefulWidget {
  const WifiStatusScreen({super.key, required this.title});

  final String title;

  @override
  State<WifiStatusScreen> createState() => _WifiStatusScreenState();
}

class _WifiStatusScreenState extends State<WifiStatusScreen> {
  String _wifiStatus = 'Checking WiFi...';
  String _wifiName = 'Unknown';
  final WifiService _wifiService = WifiService();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    
    // Listen for connectivity changes
    _connectivitySubscription = _wifiService
        .getConnectivityStream()
        .listen((ConnectivityResult result) {
      _checkWifiStatus();
    });
  }
  
  Future<void> _initPermissions() async {
    // Request location permission for Android 10+
    if (await PermissionService.requestLocationPermission()) {
      _checkWifiStatus();
    } else {
      if (mounted) {
        setState(() {
          _wifiStatus = 'Location permission required';
          _wifiName = 'Please grant location permission';
        });
        // Show permission dialog only if the widget is still mounted
        await PermissionService.showPermissionDialog(context);
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkWifiStatus() async {
    final wifiStatusMap = await _wifiService.getWifiStatus();
    
    if (mounted) {
      setState(() {
        _wifiStatus = wifiStatusMap['status'] ?? 'Unknown status';
        _wifiName = wifiStatusMap['ssid'] ?? 'Unknown SSID';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const HeaderText(text: 'WiFi Connection Status:'),
              const SizedBox(height: 20),
              StatusTextField(text: _wifiStatus, label: 'Status'),
              const SizedBox(height: 20),
              const HeaderText(text: 'Current WiFi SSID:'),
              const SizedBox(height: 20),
              StatusTextField(text: _wifiName, label: 'SSID'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkWifiStatus,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}