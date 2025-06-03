class Eta {
  final DateTime updatedTime = DateTime.now();

  final bool isRealTime;
  final int arrivalTime;

  Eta({required this.isRealTime, required this.arrivalTime});

  Eta.fromJson(Map<String, dynamic> json)
    : isRealTime = json['isRealTime'] as bool,
      arrivalTime = json['arrivalTime'] as int;
}
