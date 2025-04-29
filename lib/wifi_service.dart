import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WifiService {
  final NetworkInfo _networkInfo = NetworkInfo();
  
  // Check if WiFi is enabled and get SSID
  Future<Map<String, String>> getWifiStatus() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.wifi) {
        // WiFi is on and connected
        final wifiName = await _networkInfo.getWifiName() ?? 'Unknown SSID';
        
        return {
          'status': 'WiFi is ON',
          'ssid': wifiName.replaceAll('"', ''), // Remove quotes from SSID if present
        };
      } else {
        // WiFi is off or not connected
        return {
          'status': 'WiFi is OFF',
          'ssid': 'Not connected',
        };
      }
    } catch (e) {
      return {
        'status': 'Error: ${e.toString()}',
        'ssid': 'Error getting SSID',
      };
    }
  }
  
  // Stream to listen for connectivity changes
  Stream<ConnectivityResult> getConnectivityStream() {
    return Connectivity().onConnectivityChanged;
  }
}