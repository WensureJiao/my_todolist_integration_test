import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../todo_riverpod.dart';
import '../utils/todo_theme.dart';
import '../utils/ui_helpers.dart';
import 'package:intl/intl.dart';

class TodoItemTile extends ConsumerWidget {
  final Todo todo;
  final int index;
  final bool isDark;

  const TodoItemTile({
    super.key,
    required this.todo,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: TodoTheme.statusColor(todo.status, isDark),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TodoTheme.textColor(isDark),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.subtitle != null && todo.subtitle!.isNotEmpty)
              Text(
                todo.subtitle!,
                style: TextStyle(color: TodoTheme.textColor(isDark)),
              ),
            if (todo.description != null && todo.description!.isNotEmpty)
              Text(
                todo.description!,
                style: TextStyle(color: TodoTheme.textColor(isDark)),
              ),
            const SizedBox(height: 4),
            Text(
              'Start: ${todo.startTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(todo.startTime!) : '-'}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              'End: ${todo.endTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(todo.endTime!) : '-'}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
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
                  ref
                      .read(todosProvider.notifier)
                      .updateTodo(index, todo.copyWith(status: newStatus));
                }
              },
              items: TodoStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => TodoUIActions.editTodoViaUI(context, ref, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  TodoUIActions.deleteTodoWithConfirm(context, ref, index),
            ),
          ],
        ),
      ),
    );
  }
}
