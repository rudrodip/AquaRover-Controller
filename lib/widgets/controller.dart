import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'slider.dart';
import 'dart:math' as math;

List<int> convertToBytes(dynamic input) {
  String stringVal = input.toString();
  List<int> bytes = List<int>.filled(stringVal.length, 0);

  for (int i = 0; i < stringVal.length; i++) {
    bytes[i] = stringVal.codeUnitAt(i);
  }

  return bytes;
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
  late TextEditingController textEditingController;
  double prevDis = 0;
  double prevDeg = 0;
  bool pumpOn = false;

  @override
  void initState() {
    textEditingController = TextEditingController();

    super.initState();
  }

  JoystickDirectionCallback onDirectionChanged(
      Future<void> Function(dynamic) writeCharacteristicWithoutResponse) {
    return (double degrees, double distance) {
      if (!(degrees >= 90 && degrees <= 270)) {
        distance = distance * -1;
      }
      degrees = 270 - degrees;
      if (degrees > 180) degrees = 360 - degrees;
      if (degrees < 0) degrees = degrees + 180;

      String output = 'd$distance,$degrees';
      final List<int> outputList = convertToBytes(output);
      debugPrint(output);
      if ((distance - prevDis).abs() > 0.50 || (degrees - prevDeg).abs() > 20) {
        writeCharacteristicWithoutResponse(outputList);
        prevDis = distance;
        prevDeg = degrees;
      }
    };
  }

  Future<void> writeCharacteristicWithResponse(input) async {
    await widget.writeWithResponse(widget.characteristic, input);
  }

  Future<void> writeCharacteristicWithoutResponse(input) async {
    await widget.writeWithoutResponse(widget.characteristic, input);
  }

  List<Widget> get writeSection => [
        TextField(
          controller: textEditingController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Value',
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => writeCharacteristicWithoutResponse(
                  convertToBytes(textEditingController.text)),
              child: const Text('Send'),
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('AquaRover Controller'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 500,
                ),
                child: AlertDialog(
                  title: const Text('Debugger'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [...writeSection],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }),
        child: const Icon(Icons.settings_applications),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Transform.rotate(
              angle: math.pi,
              child: JoystickView(
                onDirectionChanged:
                    onDirectionChanged(writeCharacteristicWithoutResponse),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            CustomSlider(
                name: 'Slider 1',
                id: 's1',
                write: writeCharacteristicWithResponse,
                convert: convertToBytes),
            CustomSlider(
                name: 'Slider 2',
                id: 's2',
                write: writeCharacteristicWithResponse,
                convert: convertToBytes),
            CustomSlider(
                name: 'Slider 3',
                id: 's3',
                write: writeCharacteristicWithResponse,
                convert: convertToBytes),
            CustomSlider(
                name: 'Slider 4',
                id: 's4',
                write: writeCharacteristicWithResponse,
                convert: convertToBytes),
            ElevatedButton(
                onPressed: () =>
                    writeCharacteristicWithResponse(pumpOn ? "p0" : "p1"),
                child: Text(pumpOn ? "Pump off" : "Pump on"))
          ],
        ),
      ));
}
