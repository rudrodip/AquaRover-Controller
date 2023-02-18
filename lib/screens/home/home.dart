import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:aquarover/services/ble/ble_device_interactor.dart';

JoystickDirectionCallback onDirectionChanged() {
  return (double degrees, double distance) {
    String data =
        "Degree : ${degrees.toStringAsFixed(2)}, distance : ${distance.toStringAsFixed(2)}";
    debugPrint(data);
  };
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) =>
      Consumer<BleDeviceInteractor>(builder: (context, interactor, _) {
        return Scaffold(
            appBar: AppBar(title: const Text('AquaRover')),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return const BottomSheetModal();
                          },
                        );
                      },
                      child: const Text('Connect')),
                  JoystickView(
                    onDirectionChanged: onDirectionChanged(),
                  ),
                  Slider(
                    value: _currentSliderValue,
                    max: 100,
                    divisions: 10,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                ],
              ),
            ));
      });
}
