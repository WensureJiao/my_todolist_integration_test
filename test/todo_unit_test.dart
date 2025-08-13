import 'package:flutter_test/flutter_test.dart';
import 'package:demo/models/todo.dart'; // 根据你的实际路径修改

void main() {
  group('Todo 序列化/反序列化测试', () {
    test('toJson should convert Todo to Map correctly', () {
      final todo = Todo(
        title: '测试标题',
        subtitle: '副标题',
        description: '描述',
        startTime: DateTime.parse('2025-08-13T10:00:00'),
        endTime: DateTime.parse('2025-08-13T12:00:00'),
        status: TodoStatus.progress,
      );

      final json = todo.toJson();

      expect(json['title'], '测试标题');
      expect(json['subtitle'], '副标题');
      expect(json['description'], '描述');
      expect(json['startTime'], '2025-08-13T10:00:00.000');
      expect(json['endTime'], '2025-08-13T12:00:00.000');
      expect(json['status'], TodoStatus.progress.index);
    });

    test('fromJson should convert Map to Todo correctly', () {
      final json = {
        'title': '测试标题',
        'subtitle': '副标题',
        'description': '描述',
        'startTime': '2025-08-13T10:00:00.000',
        'endTime': '2025-08-13T12:00:00.000',
        'status': TodoStatus.progress.index,
      };

      final todo = Todo.fromJson(json);

      expect(todo.title, '测试标题');
      expect(todo.subtitle, '副标题');
      expect(todo.description, '描述');
      expect(todo.startTime, DateTime.parse('2025-08-13T10:00:00'));
      expect(todo.endTime, DateTime.parse('2025-08-13T12:00:00'));
      expect(todo.status, TodoStatus.progress);
    });

    test('fromJson should handle missing optional fields and status', () {
      final json = {'title': '只有标题'};

      final todo = Todo.fromJson(json);

      expect(todo.title, '只有标题');
      expect(todo.subtitle, null);
      expect(todo.description, null);
      expect(todo.startTime, null);
      expect(todo.endTime, null);
      expect(todo.status, TodoStatus.waiting); // 默认值
    });

    test('toJson should handle null optional fields', () {
      final todo = Todo(title: '只有标题');

      final json = todo.toJson();

      expect(json['title'], '只有标题');
      expect(json['subtitle'], null);
      expect(json['description'], null);
      expect(json['startTime'], null);
      expect(json['endTime'], null);
      expect(json['status'], TodoStatus.waiting.index);
    });
  });
}
