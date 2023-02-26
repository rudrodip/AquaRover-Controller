import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:aquarover/models/datapoint.dart';
import 'package:aquarover/models/circular_buffer.dart';
import 'package:aquarover/functions/parse_json.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'calibration_dialog.dart';

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
  final envTempBuffer = CircularBuffer();
  final humidBuffer = CircularBuffer();
  final tdsBuffer = CircularBuffer();
  final turbidityBuffer = CircularBuffer();

  double tempCalibConst = 0;
  double envTempCalibConst = 0;
  double humidCalibConst = 0;
  double tdsCalibConst = 0;
  double turbidityCalibConst = 0;

  String readOutput = '';

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
    setState(() {
      readOutput = stringResult;
    });

    final Map<String, double> jsonData = parseJson(stringResult);

    String currentTime = DateFormat('hh:mm:ss').format(DateTime.now());
    jsonData.containsKey('temperature')
        ? tempBuffer.addDataPoint(currentTime,
            jsonData['temperature']!.toDouble() + tempCalibConst.toDouble())
        : '';
    jsonData.containsKey('humidity')
        ? humidBuffer.addDataPoint(currentTime,
            jsonData['humidity']!.toDouble() + humidCalibConst.toDouble())
        : '';
    jsonData.containsKey('tds')
        ? tdsBuffer.addDataPoint(
            currentTime, jsonData['tds']!.toDouble() + tdsCalibConst.toDouble())
        : '';
    jsonData.containsKey('turbidity')
        ? turbidityBuffer.addDataPoint(currentTime,
            jsonData['turbidity']!.toDouble() + turbidityCalibConst.toDouble())
        : '';
    jsonData.containsKey('env_temperature')
        ? turbidityBuffer.addDataPoint(
            currentTime,
            jsonData['env_temperature']!.toDouble() +
                envTempCalibConst.toDouble())
        : '';

    if (mounted) {
      setState(() {
        readOutput = stringResult;
      });
    }
  }

  void _updateTempCalibConst(double c) {
    tempCalibConst = c;
  }

  void _updateHumidCalibConst(double c) {
    humidCalibConst = c;
  }

  void _updateEnvTempCalibConst(double c) {
    envTempCalibConst = c;
  }

  void _updateTDSCalibConst(double c) {
    tdsCalibConst = c;
  }

  void _updateTurbidityCalibConst(double c) {
    turbidityCalibConst = c;
  }

  Widget sectionHeader(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Data Visualization'),
          automaticallyImplyLeading: false,
        ),
        floatingActionButton: SpeedDial(
          children: [
            SpeedDialChild(
              child: const Icon(Icons.water_drop),
              label: 'Water Temperature',
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return CalibrationDialog(
                      name: "Water Temperature",
                      buffer: tempBuffer,
                      updateCalibConst: _updateTempCalibConst,
                    );
                  }),
            ),
            SpeedDialChild(
              child: const Icon(Icons.sunny),
              label: 'Environment Temperature',
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return CalibrationDialog(
                      name: "Environment Temperature",
                      buffer: envTempBuffer,
                      updateCalibConst: _updateEnvTempCalibConst,
                    );
                  }),
            ),
            SpeedDialChild(
              child: const Icon(Icons.foggy),
              label: 'Environment Humidity',
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return CalibrationDialog(
                      name: "Environment Humidity",
                      buffer: humidBuffer,
                      updateCalibConst: _updateHumidCalibConst,
                    );
                  }),
            ),
            SpeedDialChild(
              child: const Icon(Icons.shape_line),
              label: 'TDS',
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return CalibrationDialog(
                      name: "TDS",
                      buffer: tdsBuffer,
                      updateCalibConst: _updateTDSCalibConst,
                    );
                  }),
            ),
            SpeedDialChild(
              child: const Icon(Icons.shape_line_rounded),
              label: 'Turbidity',
              onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return CalibrationDialog(
                      name: "Turbidity",
                      buffer: turbidityBuffer,
                      updateCalibConst: _updateTurbidityCalibConst,
                    );
                  }),
            ),
          ],
          child: const Icon(Icons.compass_calibration),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                'Realtime data from AquaRover',
                style: TextStyle(
                  color: Colors.cyan[400],
                  fontSize: 25,
                ),
              ),
            ),

            //Initialize the chart widget
            SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Water Temperature (deg C)'),
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
                  activationMode: ActivationMode.longPress,
                  enable: true,
                ),
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
                title: ChartTitle(text: 'Environment Temperature (deg C)'),
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
                  activationMode: ActivationMode.longPress,
                  enable: true,
                ),
                series: <ChartSeries<DataPoint, String>>[
                  LineSeries<DataPoint, String>(
                    dataSource: envTempBuffer.getBuffer(),
                    xValueMapper: (DataPoint tempData, _) => tempData.time,
                    yValueMapper: (DataPoint tempData, _) => tempData.variable,
                    name: 'Temperature',
                  )
                ]),
            tempBuffer.last().variable != 0
                ? Text(
                    'Environment Temperature: ${envTempBuffer.last().variable} C')
                : const Text('Environment Temperature sensor not connected'),
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
                ? Text(
                    'Relative Turbidity: ${turbidityBuffer.last().variable}%')
                : const Text('Turbidity sensor not connected'),
            const SizedBox(
              height: 32,
            ),
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 500,
                        ),
                        child: AlertDialog(
                          title: const Text(
                            'Instant Reading',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Received: $readOutput'),
                                tempBuffer.last().variable != 0
                                    ? Text(
                                        'Temperature: ${tempBuffer.last().variable} C')
                                    : const Text(
                                        'Temperature sensor not connected'),
                                humidBuffer.last().variable != 0
                                    ? Text(
                                        'Relative Humidity: ${humidBuffer.last().variable} %')
                                    : const Text(
                                        'Humidity sensor not connected'),
                                tdsBuffer.last().variable != 0
                                    ? Text(
                                        'Relative TDS: ${tempBuffer.last().variable}%')
                                    : const Text('TDS sensor not connected'),
                                turbidityBuffer.last().variable != 0
                                    ? Text(
                                        'Relative Turbidity: ${tempBuffer.last().variable}%')
                                    : const Text(
                                        'Turbidity sensor not connected'),
                                const SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Snapshot')),
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
                child: const Icon(Icons.drafts))
          ]),
        ));
  }
}
