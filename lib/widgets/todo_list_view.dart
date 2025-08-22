import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

import 'todo_item_tile.dart';

class TodoListView extends ConsumerWidget {
  final List<Todo> todos;
  final bool isDark;

  const TodoListView({super.key, required this.todos, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoItemTile(todo: todo, index: index, isDark: isDark);
        },
      ),
    );
  }
}
