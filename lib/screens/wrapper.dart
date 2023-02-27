import 'package:aquarover/screens/authenticate/signin.dart';
import 'package:aquarover/screens/data/data.dart';
import 'package:aquarover/screens/profile/profile.dart';
import 'package:aquarover/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aquarover/widgets/controller.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';

class Wrapper extends StatefulWidget {
  const Wrapper({
    required this.characteristic,
    required this.readCharacteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
    Key? key,
  }) : super(key: key);

  final QualifiedCharacteristic characteristic;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int currentPage = 0;
  late final QualifiedCharacteristic characteristic;
  late final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
  late final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;

  late final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  late final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;
  late List<Widget> pages;

  @override
  void initState() {
    characteristic = widget.characteristic;
    readCharacteristic = widget.readCharacteristic;
    writeWithResponse = widget.writeWithResponse;
    subscribeToCharacteristic = widget.subscribeToCharacteristic;
    writeWithoutResponse = widget.writeWithoutResponse;

    pages = [
      ControllerScreen(
        characteristic: characteristic,
        readCharacteristic: readCharacteristic,
        writeWithResponse: writeWithResponse,
        writeWithoutResponse: writeWithoutResponse,
        subscribeToCharacteristic: subscribeToCharacteristic,
      ),
      Data(
        characteristic: characteristic,
        readCharacteristic: readCharacteristic,
      ),
      const Profile(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.gamepad), label: 'Controller'),
          NavigationDestination(
              icon: Icon(Icons.data_exploration), label: 'Data'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}
