import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/todo.dart';

enum SortType { title, startTime, status }
// ------------------------ Providers ------------------------

// 所有 TODO 列表的状态
final todosProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((
  ref,
) {
  return TodoListNotifier();
});

// 当前排序方式
final sortProvider = StateProvider<SortType>((ref) => SortType.title);

// Theme 状态
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// ------------------------ Notifiers ------------------------

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList('todos') ?? [];
    state = todosJson.map((e) => Todo.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'todos',
      state.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  void addTodo(Todo todo) {
    state = [...state, todo];
    saveTodos();
  }

  void updateTodo(int index, Todo todo) {
    final list = [...state];
    list[index] = todo;
    state = list;
    saveTodos();
  }

  void deleteTodo(int index) {
    final list = [...state]..removeAt(index);
    state = list;
    saveTodos();
  }

  void sortTodos(SortType type) {
    final list = [...state];
    list.sort((a, b) {
      switch (type) {
        case SortType.title:
          return a.title.compareTo(b.title);
        case SortType.startTime:
          return (a.startTime ?? DateTime(2100)).compareTo(
            b.startTime ?? DateTime(2100),
          );
        case SortType.status:
          return a.status.index.compareTo(b.status.index);
      }
    });
    state = list;
  }

  void addRandomTodos(int count) {
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
    state = [...state, ...newTodos];
    saveTodos();
  }

  void cleanAll() {
    state = [];
    saveTodos();
  }
}

// ------------------------ Theme ------------------------

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
