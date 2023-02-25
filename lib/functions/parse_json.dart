Map<String, double> parseJson(String input) {
  Map<String, double> jsonMap = {};

  RegExp pattern = RegExp(r"([a-zA-Z]+)(-?\d*\.?\d+)");
  pattern.allMatches(input).forEach((match) {
    String key = match.group(1) ?? '';
    double value = double.parse(match.group(2) ?? '');
    jsonMap[key] = value;
  });

  return jsonMap;
}
