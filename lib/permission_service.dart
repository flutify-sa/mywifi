import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }
  
  // Check if location permission is already granted
  static Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }
  
  // Show dialog explaining why we need the permission
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
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
}