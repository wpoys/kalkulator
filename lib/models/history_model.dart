class HistoryModel {
  final int? id;
  final String expression;
  final String result;
  final String? title;
  final String createdAt;

  const HistoryModel({
    this.id,
    required this.expression,
    required this.result,
    this.title,
    required this.createdAt,
  });

  HistoryModel copyWith({
    int? id,
    String? expression,
    String? result,
    String? title,
    String? createdAt,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expression': expression,
      'result': result,
      'title': title,
      'created_at': createdAt,
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int?,
      expression: map['expression'] as String,
      result: map['result'] as String,
      title: map['title'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
