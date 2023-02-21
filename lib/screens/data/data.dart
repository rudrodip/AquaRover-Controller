import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:aquarover/models/datapoint.dart';
import 'package:aquarover/models/circular_buffer.dart';

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
  final tdsBuffer = CircularBuffer();
  final turbidityBuffer = CircularBuffer();

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
    jsonData.containsKey('temperature')
        ? tempBuffer.addDataPoint(
            currentTime, jsonData['temperature'].toDouble())
        : '';
    jsonData.containsKey('humidity')
        ? humidBuffer.addDataPoint(currentTime, jsonData['humidity'].toDouble())
        : '';
    jsonData.containsKey('tds')
        ? tdsBuffer.addDataPoint(currentTime, jsonData['tds'].toDouble())
        : '';
    jsonData.containsKey('turbidity')
        ? tdsBuffer.addDataPoint(currentTime, jsonData['turbidity'].toDouble())
        : '';
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                  ),
                  child: AlertDialog(
                    title: const Text('Instant Reading'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tempBuffer.last().variable != 0
                              ? Text(
                                  'Temperature: ${tempBuffer.last().variable} C')
                              : const Text('Temperature sensor not connected'),
                          humidBuffer.last().variable != 0
                              ? Text(
                                  'Relative Humidity: ${humidBuffer.last().variable} %')
                              : const Text('Humidity sensor not connected'),
                          tdsBuffer.last().variable != 0
                              ? Text(
                                  'Relative TDS: ${tempBuffer.last().variable}%')
                              : const Text('TDS sensor not connected'),
                          turbidityBuffer.last().variable != 0
                              ? Text(
                                  'Relative Turbidity: ${tempBuffer.last().variable}%')
                              : const Text('Turbidity sensor not connected'),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              onPressed: () {}, child: const Text('Snapshot')),
                        ],
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
          child: const Icon(Icons.settings_backup_restore),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                zoomPanBehavior: null,
                crosshairBehavior: null,
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                    dataSource: tempBuffer.getBuffer(),
                    xValueMapper: (DataPoint tempData, _) => tempData.time,
                    yValueMapper: (DataPoint tempData, _) => tempData.variable,
                    name: 'Temperature',
                  )
                ]),
            tempBuffer.last().variable != 0
                ? Text('Temperature: ${tempBuffer.last().variable} C')
                : const Text('Temperature sensor not connected'),
            const SizedBox(
              height: 32,
            ),
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
                zoomPanBehavior: null,
                crosshairBehavior: null,
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                    dataSource: humidBuffer.getBuffer(),
                    xValueMapper: (DataPoint humidData, _) => humidData.time,
                    yValueMapper: (DataPoint humidData, _) =>
                        humidData.variable,
                    name: 'Humidity',
                  ),
                ]),
            humidBuffer.last().variable != 0
                ? Text('Relative Humidity: ${humidBuffer.last().variable} %')
                : const Text('Humidity sensor not connected'),
            const SizedBox(
              height: 32,
            ),
            SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'TDS (relative %)'),
                // Enable legend
                legend: Legend(isVisible: false),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                zoomPanBehavior: null,
                crosshairBehavior: null,
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                    dataSource: tdsBuffer.getBuffer(),
                    xValueMapper: (DataPoint tdsData, _) => tdsData.time,
                    yValueMapper: (DataPoint tdsData, _) => tdsData.variable,
                    name: 'TDS',
                  ),
                ]),
            tdsBuffer.last().variable != 0
                ? Text('Relative TDS: ${tdsBuffer.last().variable}%')
                : const Text('TDS sensor not connected'),
            const SizedBox(
              height: 32,
            ),
            SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Turbidity (relative %)'),
                // Enable legend
                legend: Legend(isVisible: false),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                zoomPanBehavior: null,
                crosshairBehavior: null,
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                    dataSource: turbidityBuffer.getBuffer(),
                    xValueMapper: (DataPoint turbidityData, _) =>
                        turbidityData.time,
                    yValueMapper: (DataPoint turbidityData, _) =>
                        turbidityData.variable,
                    name: 'Turbidity',
                  ),
                ]),
            turbidityBuffer.last().variable != 0
                ? Text('Relative Turbidity: ${tempBuffer.last().variable}%')
                : const Text('Turbidity sensor not connected'),
            const SizedBox(
              height: 32,
            ),
          ]),
        ));
  }
}
