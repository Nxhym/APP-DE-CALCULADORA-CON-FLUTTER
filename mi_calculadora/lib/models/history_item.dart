class HistoryItem {
  final String operation;
  final String result;
  final DateTime timestamp;

  HistoryItem({
    required this.operation, 
    required this.result, 
    required this.timestamp
  });

  // Serialización para SharedPreferences
  Map<String, dynamic> toJson() => {
    'operation': operation,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    operation: json['operation'],
    result: json['result'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}