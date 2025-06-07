class Eta {
  final bool isRealTime;
  final int arrivalTime;

  Eta({required this.isRealTime, required this.arrivalTime});

  Eta.fromJson(Map<String, dynamic> json)
    : isRealTime = json['isRealTime'] as bool,
      // Standardize arrivalTime to an integer
      arrivalTime = num.parse(json["arrivalTime"].toString()).toInt();
}
