import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';

JoystickDirectionCallback onDirectionChanged() {
  return (double degrees, double distance) {
    String data =
        "Degree : ${degrees.toStringAsFixed(2)}, distance : ${distance.toStringAsFixed(2)}";
    debugPrint(data);
  };
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('AquaRover')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Connect')),
              JoystickView(
                onDirectionChanged: onDirectionChanged(),
              )
            ],
          ),
        ));
  }
}
