// utils/todo_generator.dart
import 'dart:math';
import '../models/todo.dart';

class TodoGenerator {
  static List<Todo> generateRandomTodos(int count) {
    final rand = Random();
    List<Todo> newTodos = List.generate(count, (i) {
      String randomString(int length) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        return List.generate(
          length,
          (_) => chars[rand.nextInt(chars.length)],
        ).join();
      }

      final randomLetters = randomString(5 + rand.nextInt(4));
      return Todo(
        title: "Task $randomLetters",
        subtitle: "Auto generated",
        description: "This is a random task",
        status: TodoStatus.values[rand.nextInt(TodoStatus.values.length)],
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
      );
    });

    return newTodos;
  }
}
