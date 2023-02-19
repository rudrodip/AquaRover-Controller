import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Data extends StatefulWidget {
  const Data({super.key});

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  List<_TempData> data = [
    _TempData('Jan 30', 35),
    _TempData('Feb 1', 28),
    _TempData('Mar 2', 34),
    _TempData('Apr 3', 32),
    _TempData('May 3', 40)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Data Visualization'),
          automaticallyImplyLeading: false,
        ),
        body: Column(children: [
          //Initialize the chart widget
          SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Temperature'),
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
              series: <ChartSeries<_TempData, String>>[
                LineSeries<_TempData, String>(
                    dataSource: data,
                    xValueMapper: (_TempData tempData, _) => tempData.time,
                    yValueMapper: (_TempData tempData, _) => tempData.temp,
                    name: 'Temperature',
                    // Enable data label
                    dataLabelSettings: const DataLabelSettings(isVisible: true))
              ])
        ]));
  }
}

class _TempData {
  _TempData(this.time, this.temp);

  final String time;
  final double temp;
}
