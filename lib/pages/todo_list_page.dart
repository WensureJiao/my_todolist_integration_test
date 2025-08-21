import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../riverpod_main.dart';
import 'todo_edit_page.dart';
import 'package:intl/intl.dart';

class TodoListPage extends ConsumerWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);
    final sortType = ref.watch(sortProvider);
    final themeMode = ref.watch(themeProvider); // 监听主题

    Color statusColor(TodoStatus status) {
      final isDark = themeMode == ThemeMode.dark;
      switch (status) {
        case TodoStatus.waiting:
          return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        case TodoStatus.progress:
          return isDark ? Colors.blue.shade700 : Colors.blue.shade300;
        case TodoStatus.done:
          return isDark ? Colors.green.shade700 : Colors.green.shade300;
      }
    }

    Color textColor() {
      return themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    }

    void changeSort(SortType type) {
      ref.read(sortProvider.notifier).state = type;
      ref.read(todosProvider.notifier).sortTodos(type);
    }

    void addTodo() async {
      final newTodo = await Navigator.push<Todo>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TodoEditPage(onSave: (t) => Navigator.pop(context, t)),
        ),
      );
      if (newTodo != null) {
        ref.read(todosProvider.notifier).addTodo(newTodo);
      }
    }

    void editTodo(int index, Todo todo) async {
      final edited = await Navigator.push<Todo>(
        context,
        MaterialPageRoute(
          builder: (_) => TodoEditPage(
            todo: todo,
            onSave: (t) => Navigator.pop(context, t),
          ),
        ),
      );
      if (edited != null) {
        ref.read(todosProvider.notifier).updateTodo(index, edited);
      }
    }

    void deleteTodo(int index) async {
      ref.read(todosProvider.notifier).deleteTodo(index);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List - Sort: ${sortType.name}'),
        actions: [
          if (todos.isNotEmpty)
            PopupMenuButton<SortType>(
              onSelected: changeSort,
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
          ? const Center(child: Text("No TODOs yet"))
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor(todo.status),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor(),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todo.subtitle != null &&
                              todo.subtitle!.isNotEmpty)
                            Text(
                              todo.subtitle!,
                              style: TextStyle(color: textColor()),
                            ),
                          if (todo.description != null &&
                              todo.description!.isNotEmpty)
                            Text(
                              todo.description!,
                              style: TextStyle(color: textColor()),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Start: ${todo.startTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(todo.startTime!) : '-'}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          Text(
                            'End: ${todo.endTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(todo.endTime!) : '-'}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<TodoStatus>(
                            value: todo.status,
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                final updated = todo.copyWith(
                                  status: newStatus,
                                );
                                ref
                                    .read(todosProvider.notifier)
                                    .updateTodo(index, updated);
                              }
                            },
                            items: TodoStatus.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.name),
                                  ),
                                )
                                .toList(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editTodo(index, todo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                    'Are you sure you want to delete this task?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                deleteTodo(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task deleted!'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
