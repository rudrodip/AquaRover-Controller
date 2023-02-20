import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

class Data extends StatefulWidget {
  const Data({
    required this.characteristic,
    required this.readCharacteristic,
    Key? key,
  }) : super(key: key);

  final QualifiedCharacteristic characteristic;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  final tempBuffer = CircularBuffer();
  final humidBuffer = CircularBuffer();
  Timer? _timer;

  @override
  void initState() {
    // call the function every second using Timer.periodic
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      readCharacteristic();
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> readCharacteristic() async {
    final result = await widget.readCharacteristic(widget.characteristic);
    String stringResult = String.fromCharCodes(result);

    final dynamic jsonData = json.decode(stringResult);
    String currentTime = DateFormat('hh:mm:ss').format(DateTime.now());

    tempBuffer.addDataPoint(currentTime, jsonData['temperature'].toDouble());
    humidBuffer.addDataPoint(currentTime, jsonData['humidity'].toDouble());
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Data Visualization'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            //Initialize the chart widget
            SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Temperature (deg C)'),
                // Enable legend
                legend: Legend(isVisible: false),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                ),
                crosshairBehavior: CrosshairBehavior(
                  enable: true,
                  activationMode: ActivationMode.longPress,
                  hideDelay: 500,
                  lineColor: Colors.red,
                ),
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                      dataSource: tempBuffer.getBuffer(),
                      xValueMapper: (DataPoint tempData, _) => tempData.time,
                      yValueMapper: (DataPoint tempData, _) =>
                          tempData.variable,
                      name: 'Temperature',
                      // Enable data label
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true))
                ]),
            SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Relative Humidity (%)'),
                // Enable legend
                legend: Legend(isVisible: false),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                ),
                crosshairBehavior: CrosshairBehavior(
                  enable: true,
                  activationMode: ActivationMode.longPress,
                  hideDelay: 500,
                  lineColor: Colors.red,
                ),
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                    dataSource: humidBuffer.getBuffer(),
                    xValueMapper: (DataPoint humidData, _) => humidData.time,
                    yValueMapper: (DataPoint humidData, _) =>
                        humidData.variable,
                    name: 'Humidity',
                    // Enable data label
                    // Enable data label
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    // Enable data point marker
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                    ),
                  ),
                ]),
          ]),
        ));
  }
}

class DataPoint {
  DataPoint(this.time, this.variable);

  final String time;
  final num variable;
}

class CircularBuffer {
  final int bufferSize = 200;
  final List<DataPoint> _buffer = List.filled(200, DataPoint('0', 0));
  int _head = 0;

  void addDataPoint(String x, double y) {
    // Update the value at the current position
    _buffer[_head] = DataPoint(x, y);

    // Increment the pointer and wrap around if it exceeds the buffer size
    _head = (_head + 1) % bufferSize;
  }

  List<DataPoint> getBuffer() {
    // Return the data points in the order they were added to the buffer
    if (_head == 0) {
      return _buffer;
    } else {
      return List<DataPoint>.from(
          _buffer.sublist(_head)..addAll(_buffer.sublist(0, _head)));
    }
  }
}
