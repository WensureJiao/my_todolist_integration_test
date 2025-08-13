enum TodoStatus { waiting, progress, done }

class Todo {
  String title;
  String? subtitle;
  String? description;
  DateTime? startTime;
  DateTime? endTime;
  TodoStatus status;

  Todo({
    required this.title,
    this.subtitle,
    this.description,
    this.startTime,
    this.endTime,
    this.status = TodoStatus.waiting,//默认waiting
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'status': status.index,
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        title: json['title'],
        subtitle: json['subtitle'],
        description: json['description'],
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        status: TodoStatus.values[json['status'] ?? 0],
      );
}
