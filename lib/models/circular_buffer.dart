import 'datapoint.dart';

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

  DataPoint last() {
    // Return the last data point in the buffer
    int tail = _head - 1;
    if (tail < 0) {
      tail = bufferSize - 1;
    }
    return _buffer[tail];
  }
}
