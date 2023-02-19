// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:aquarover/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:aquarover/services/ble/ble_device_connector.dart';
import 'package:aquarover/services/ble/ble_device_interactor.dart';
import 'package:aquarover/services/ble/ble_scanner.dart';
import 'package:aquarover/services/ble/ble_status_monitor.dart';
import 'services/ble/ble_logger.dart';
import 'package:aquarover/screens/home/home.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _ble = FlutterReactiveBle();
    final _bleLogger = BleLogger(ble: _ble);
    final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
    final _monitor = BleStatusMonitor(_ble);
    final _connector = BleDeviceConnector(
      ble: _ble,
      logMessage: _bleLogger.addToLog,
    );
    final _serviceDiscoverer = BleDeviceInteractor(
      bleDiscoverServices: _ble.discoverServices,
      readCharacteristic: _ble.readCharacteristic,
      writeWithResponse: _ble.writeCharacteristicWithResponse,
      writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
      subscribeToCharacteristic: _ble.subscribeToCharacteristic,
      logMessage: _bleLogger.addToLog,
    );

    return MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        Provider.value(value: _monitor),
        Provider.value(value: _connector),
        Provider.value(value: _serviceDiscoverer),
        Provider.value(value: _bleLogger),
        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => _monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => _connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
        StreamProvider<User?>.value(
            initialData: null, value: Auth().authStateChanges),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.cyan),
        home: const Home(),
      ),
    );
  }
}
