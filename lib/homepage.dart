import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _wifiStatus = 'Checking WiFi...';
  String _wifiName = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      _checkWifiStatus();
    });
  }
  
  Future<void> _initPermissions() async {
    // Request location permission for Android 10+
    if (await Permission.location.request().isGranted) {
      _checkWifiStatus();
    } else {
      setState(() {
        _wifiStatus = 'Location permission required';
        _wifiName = 'Please grant location permission';
      });
      _showPermissionDialog();
    }
  }
  
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
            "This app needs location permission to access WiFi information. "
            "This is required by Android for security reasons, even though the "
            "app only needs to access the current WiFi information."
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkWifiStatus() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.wifi) {
        // WiFi is on and connected
        final wifiName = await _networkInfo.getWifiName() ?? 'Unknown SSID';
        
        setState(() {
          _wifiStatus = 'WiFi is ON';
          _wifiName = wifiName.replaceAll('"', ''); // Remove quotes from SSID if present
        });
      } else {
        // WiFi is off or not connected
        setState(() {
          _wifiStatus = 'WiFi is OFF';
          _wifiName = 'Not connected';
        });
      }
    } catch (e) {
      setState(() {
        _wifiStatus = 'Error: ${e.toString()}';
        _wifiName = 'Error getting SSID';
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
              const Text(
                'WiFi Connection Status:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: _wifiStatus),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Status',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Current WiFi SSID:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: _wifiName),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'SSID',
                ),
              ),
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