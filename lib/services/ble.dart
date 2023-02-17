// import 'dart:async';
// import 'package:flutter_blue/flutter_blue.dart';

// class Ble {
//   BluetoothDevice? device;
//   BluetoothCharacteristic? characteristic;

//   Future<void> connectToBleDevice() async {
//     // Scan for BLE devices
//     final flutterBlue = FlutterBlue.instance;
//     flutterBlue.startScan(timeout: const Duration(seconds: 4));

//     // Find the device with matching name
//     const deviceName = 'ESP32_BLE';
//     await flutterBlue.scanResults.firstWhere((results) {
//       return results.any((device) => device.name == deviceName);
//     });

//     // Stop scanning and connect to the device
//     flutterBlue.stopScan();
//     device = await flutterBlue.connect(deviceName).timeout(
//       const Duration(seconds: 4),
//       onTimeout: () => throw Exception('Failed to connect to $deviceName'),
//     );
//   }

//   Future<void> disconnectFromBleDevice() async {
//     if (device != null) {
//       await device!.disconnect();
//     }
//   }

//   Future<void> readFromBleService() async {
//     if (device != null) {
//       final services = await device!.discoverServices();
//       final service = services.firstWhere(
//         (s) => s.uuid.toString() == '0000ffe0-0000-1000-8000-00805f9b34fb',
//         orElse: () => throw Exception('Service not found'),
//       );
//       characteristic = service.characteristics.firstWhere(
//         (c) => c.uuid.toString() == '0000ffe1-0000-1000-8000-00805f9b34fb',
//         orElse: () => throw Exception('Characteristic not found'),
//       );
//       await characteristic!.setNotifyValue(true);
//       characteristic!.value.listen((data) {
//         // Handle incoming data
//         print('Received data: $data');
//       });
//     }
//   }

//   Future<void> writeToBleService(String message) async {
//     if (device != null && characteristic != null) {
//       final bytes = message.codeUnits;
//       await characteristic!.write(bytes);
//     }
//   }
// }
