import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../todo_riverpod.dart';
import '../pages/todo_edit_page.dart';
import '../theme_riverpod.dart';

class TodoUIActions {
  static Future<void> addTodoViaUI(BuildContext context, WidgetRef ref) async {
    final newTodo = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(
        builder: (_) => TodoEditPage(onSave: (t) => Navigator.pop(context, t)),
      ),
    );
    if (newTodo != null) {
      ref.read(todosProvider.notifier).addTodo(newTodo);
    }
  }

  static Future<void> editTodoViaUI(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final todos = ref.read(todosProvider);
    final edited = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(
        builder: (_) => TodoEditPage(
          todo: todos[index],
          onSave: (t) => Navigator.pop(context, t),
        ),
      ),
    );
    if (edited != null) {
      ref.read(todosProvider.notifier).updateTodo(index, edited);
    }
  }

  static Future<void> deleteTodoWithConfirm(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(todosProvider.notifier).deleteTodoAt(index);
    }
  }

  /// 清空所有 Todos
  static void cleanAllTodos(BuildContext context, WidgetRef ref) {
    ref.read(todosProvider.notifier).cleanAll();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("All todos cleared!")));
  }

  /// 切换主题
  static void toggleThemeMode(BuildContext context, WidgetRef ref) {
    ref.read(themeProvider.notifier).toggleTheme();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Theme toggled!")));
  }
}
