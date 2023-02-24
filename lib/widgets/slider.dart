import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider({
    required this.name,
    required this.id,
    required this.write,
    required this.convert,
    this.minRange = 0,
    this.maxRange = 180,
    this.divider = 18,
    Key? key,
  }) : super(key: key);

  final String name;
  final String id;
  final Future Function(void) write;
  final List<int> Function(dynamic) convert;
  final double minRange;
  final double maxRange;
  final int divider;

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(widget.name),
        Slider(
          value: _currentSliderValue,
          min: widget.minRange,
          max: widget.maxRange,
          divisions: widget.divider,
          label: _currentSliderValue.round().toString(),
          onChangeEnd: (double value) =>
              widget.write(widget.convert('${widget.id}: $value')),
          onChanged: (double value) {
            setState(() {
              _currentSliderValue = value;
            });
          },
        ),
      ],
    );
  }
}
