import 'package:flutter/material.dart';
import 'package:aquarover/models/circular_buffer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:aquarover/models/datapoint.dart';

class CalibrationDialog extends StatefulWidget {
  const CalibrationDialog({
    required this.name,
    required this.updateCalibConst,
    required this.buffer,
    Key? key,
  }) : super(key: key);

  final CircularBuffer buffer;
  final String name;
  final Function(double c) updateCalibConst;

  @override
  State<CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends State<CalibrationDialog> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calibration Dialog ${widget.name}')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: widget.name),
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
                    dataSource: widget.buffer.getBuffer(),
                    xValueMapper: (DataPoint turbidityData, _) =>
                        turbidityData.time,
                    yValueMapper: (DataPoint turbidityData, _) =>
                        turbidityData.variable,
                    name: widget.name,
                  ),
                ]),
            Text('Temperature: ${widget.buffer.last().variable}'),
            Slider(
              value: _currentSliderValue,
              min: 0,
              max: 100,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                  widget.buffer.increaseVarPoints(value);
                  // widget.updateCalibConst(value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
