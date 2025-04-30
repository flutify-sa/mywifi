import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../wifi_service.dart';
import '../permission_service.dart';
import '../wifi_status_widgets.dart';
import 'package:flutter_signal_strength/flutter_signal_strength.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

class WifiStatusScreen extends StatefulWidget {
  const WifiStatusScreen({super.key, required this.title});

  final String title;

  @override
  State<WifiStatusScreen> createState() => _WifiStatusScreenState();
}

class _WifiStatusScreenState extends State<WifiStatusScreen> {
  String _wifiStatus = 'Checking WiFi...';
  String _wifiName = 'Unknown';
  int? _wifiSignalStrength; // New state variable
  final WifiService _wifiService = WifiService();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final FlutterSignalStrength _signalStrengthPlugin = FlutterSignalStrength();

  @override
  void initState() {
    super.initState();
    _initPermissions();

    // Listen for connectivity changes
    _connectivitySubscription = _wifiService
        .getConnectivityStream()
        .listen((ConnectivityResult result) {
      _checkWifiStatus();
      _getWifiSignalStrength(); // Call to get signal strength on connectivity change
    });
  }

  Future<void> _initPermissions() async {
    if (Platform.isAndroid) {
      // Request necessary permissions for Android
      if (await Permission.location.request().isGranted &&
          await Permission.phone.request().isGranted) {
        _checkWifiStatus();
        _getWifiSignalStrength(); // Call to get signal strength after permissions
      } else {
        if (mounted) {
          setState(() {
            _wifiStatus = 'Location and Phone permissions required';
            _wifiName = 'Please grant necessary permissions';
          });
          await PermissionService.showPermissionDialog(context); // You might want to update the dialog message
        }
      }
    } else {
      // For iOS, location permission might be sufficient
      if (await PermissionService.requestLocationPermission()) {
        _checkWifiStatus();
        _getWifiSignalStrength(); // Call to get signal strength after permissions
      } else {
        if (mounted) {
          setState(() {
            _wifiStatus = 'Location permission required';
            _wifiName = 'Please grant location permission';
          });
          await PermissionService.showPermissionDialog(context);
        }
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

  Future<void> _getWifiSignalStrength() async {
    try {
      final int? signalLevel = await _signalStrengthPlugin.getWifiSignalStrength();
      if (mounted) {
         setState(() {
          _wifiSignalStrength = signalLevel;
          print('WiFi Signal Strength (dBm): $_wifiSignalStrength'); // For debugging
        });
      }
    } catch (e) {
      print('Error getting WiFi signal strength: $e');
      if (mounted) {
        setState(() {
          _wifiSignalStrength = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'assets/wifi.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              const HeaderText(text: 'WiFi Connection Status:'),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: StatusTextField(text: _wifiStatus, label: 'Status'),
              ),
              const SizedBox(height: 20),
              const HeaderText(text: 'Current WiFi SSID:'),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: StatusTextField(text: _wifiName, label: 'SSID'),
              ),
              const SizedBox(height: 20),
              const HeaderText(text: 'WiFi Signal Strength:'),
              const SizedBox(height: 20),
              Text(
                _wifiSignalStrength != null
                    ? 'dBm: $_wifiSignalStrength'
                    : 'Not available',
                style: const TextStyle(fontSize: 16),
              ),
              // Here is where we will add the gauge widget later
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _checkWifiStatus();
          _getWifiSignalStrength(); // Call to refresh signal strength
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}