import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import 'todo_edit_page.dart';

enum SortType { title, startTime, status }

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];
  SortType sortType = SortType.title;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoList = prefs.getStringList('todos') ?? [];
    setState(() {
      todos = todoList.map((e) => Todo.fromJson(json.decode(e))).toList();
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoList = todos.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('todos', todoList);
  }

  void _addTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TodoEditPage(
          onSave: (todo) {
            setState(() {
              todos.add(todo);
              _sortTodos();
              _saveTodos();
            });
          },
        ),
      ),
    );
  }

  void _editTodo(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TodoEditPage(
          todo: todos[index],
          onSave: (todo) {
            setState(() {
              todos[index] = todo;
              _sortTodos();
              _saveTodos();
            });
          },
        ),
      ),
    );
  }

  void _removeTodoConfirm(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this TODO?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                todos.removeAt(index);
                _saveTodos();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sortTodos() {
    todos.sort((a, b) {
      switch (sortType) {
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
  }

  void _changeSort(SortType type) {
    setState(() {
      sortType = type;
      _sortTodos();
      _saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List - Sort: ${sortType.name}'),
        actions: [
          if (todos.isNotEmpty)
            PopupMenuButton<SortType>(
              key: const Key('sort_menu'),
              onSelected: _changeSort,
              itemBuilder: (context) => SortType.values
                  .map(
                    (type) => PopupMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          if (sortType == type)
                            const Icon(Icons.check, size: 18),
                          Text(type.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(child: Text('No TODOs yet'))
          : ListView.builder(
              key: const Key('todo_list'),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return ListTile(
                  title: Text(todo.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todo.subtitle != null && todo.subtitle!.isNotEmpty)
                        Text(
                          todo.subtitle!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      if (todo.description != null &&
                          todo.description!.isNotEmpty)
                        Text(
                          todo.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Start: ${todo.startTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(todo.startTime!) : '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'End: ${todo.endTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(todo.endTime!) : '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<TodoStatus>(
                        key: const Key('todo_status'),
                        value: todo.status,
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            setState(() {
                              todos[index] = Todo(
                                title: todo.title,
                                subtitle: todo.subtitle,
                                description: todo.description,
                                startTime: todo.startTime,
                                endTime: todo.endTime,
                                status: newStatus,
                              );
                              _saveTodos();
                            });
                          }
                        },
                        items: TodoStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.name),
                          );
                        }).toList(),
                      ),
                      PopupMenuButton<String>(
                        key: const Key('todo_actions'),
                        onSelected: (value) {
                          if (value == 'edit') _editTodo(index);
                          if (value == 'delete') _removeTodoConfirm(index);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
