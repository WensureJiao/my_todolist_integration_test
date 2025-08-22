import 'dart:convert';

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

// ------------------------ Notifiers ------------------------

class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]) {
    loadTodos();
  }
  void addTodo(Todo todo) {
    state = [...state, todo];
    saveTodos();
  }

  void deleteTodoAt(int index) {
    final list = [...state]..removeAt(index);
    state = list;
    saveTodos();
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

  void updateTodo(int index, Todo todo) {
    final list = [...state];
    list[index] = todo;
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

  void addMultiple(List<Todo> todos) {
    state = [...state, ...todos];
    saveTodos();
  }

  void cleanAll() {
    state = [];
    saveTodos();
  }
}
