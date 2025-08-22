import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../todo_riverpod.dart';
import '../utils/ui_helpers.dart';

import '../widgets/empty_todo_view.dart';
import '../widgets/todo_list_view.dart';

import '../theme_riverpod.dart';

class TodoListPage extends ConsumerWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);
    final sortType = ref.watch(sortProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List - Sort: ${sortType.name}'),
        actions: [
          if (todos.isNotEmpty)
            PopupMenuButton<SortType>(
              onSelected: (SortType type) {
                ref.read(sortProvider.notifier).state = type;
                ref.read(todosProvider.notifier).sortTodos(type);
              },
              itemBuilder: (context) => SortType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      if (sortType == type) const Icon(Icons.check, size: 18),
                      const SizedBox(width: 4),
                      Text(type.name),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      body: todos.isEmpty
          ? const EmptyTodoView()
          : TodoListView(todos: todos, isDark: isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TodoUIActions.addTodoViaUI(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
