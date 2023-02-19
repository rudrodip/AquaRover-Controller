import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';

List<int> convertToBytes(dynamic input) {
  String stringVal = input.toString();
  List<int> bytes = List<int>.filled(stringVal.length, 0);

  for (int i = 0; i < stringVal.length; i++) {
    bytes[i] = stringVal.codeUnitAt(i);
  }

  return bytes;
}

JoystickDirectionCallback onDirectionChanged(
    Future<void> Function(dynamic) writeCharacteristicWithResponse) {
  return (double degrees, double distance) {
    String output = 'd$distance,$degrees';
    final List<int> outputList = convertToBytes(output);
    writeCharacteristicWithResponse(outputList);
  };
}

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({
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
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  double _currentSliderValue = 0;
  late TextEditingController textEditingController;
  late String readOutput;

  @override
  void initState() {
    textEditingController = TextEditingController();
    readOutput = '';

    super.initState();
  }

  Future<void> writeCharacteristicWithResponse(input) async {
    await widget.writeWithResponse(widget.characteristic, input);
  }

  Future<void> writeCharacteristicWithoutResponse(input) async {
    await widget.writeWithoutResponse(widget.characteristic, input);
  }

  Future<void> readCharacteristic() async {
    final result = await widget.readCharacteristic(widget.characteristic);
    String stringResult = String.fromCharCodes(result);
    setState(() {
      readOutput = stringResult;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('AquaRover Controller'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            JoystickView(
              onDirectionChanged:
                  onDirectionChanged(writeCharacteristicWithResponse),
            ),
            Slider(
              value: _currentSliderValue,
              max: 100,
              divisions: 10,
              label: _currentSliderValue.round().toString(),
              onChangeEnd: (double value) {
                writeCharacteristicWithResponse(convertToBytes(value));
              },
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: readCharacteristic,
              child: const Text("read"),
            ),
            Text(readOutput)
          ],
        ),
      ));
}
