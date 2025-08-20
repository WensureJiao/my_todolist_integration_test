import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'todo_edit_page.dart';
import 'package:intl/intl.dart';

enum SortType { title, startTime, status }

class TodoListPage extends StatefulWidget {
  final ValueNotifier<int> todoNotifier; // 用于批量刷新
  const TodoListPage({Key? key, required this.todoNotifier}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> _todos = [];
  SortType _sortType = SortType.title;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    widget.todoNotifier.addListener(
      () => _loadTodos(),
    ); //给valueNotifier添加监听器,当value改变时触发_loadTodos
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList('todos') ?? [];
    setState(() {
      _todos = todosJson.map((e) => Todo.fromJson(jsonDecode(e))).toList();
      _sortTodos();
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'todos',
      _todos.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  void _sortTodos() {
    _todos.sort((a, b) {
      switch (_sortType) {
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
      _sortType = type;
      _sortTodos();
    });
  }

  // 根据状态和主题返回背景颜色
  Color _statusColor(TodoStatus status) {
    final brightness = Theme.of(context).brightness; // 获取当前主题亮度
    switch (status) {
      case TodoStatus.waiting:
        return brightness ==
                Brightness
                    .dark //判断当前的主题亮度
            ? Colors
                  .grey
                  .shade700 // 深色主题灰色
            : Colors.grey.shade300; // 浅色主题灰色
      case TodoStatus.progress:
        return brightness == Brightness.dark
            ? Colors.blue.shade700
            : Colors.blue.shade300;
      case TodoStatus.done:
        return brightness == Brightness.dark
            ? Colors.green.shade700
            : Colors.green.shade300;
    }
  }

  // 根据主题返回字体颜色
  Color _textColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  void _editTodo(int index) async {
    final edited = await Navigator.push<Todo>(
      //<Todo> 表示：当这个页面关闭时，会返回一个 Todo 类型的对象。
      context,
      MaterialPageRoute(
        builder: (_) => TodoEditPage(
          todo: _todos[index],
          onSave: (t) => Navigator.pop(context, t),
        ),
      ),
    );
    if (edited != null) {
      // 只要用户点击了save，就会返回一个非null的Todo对象
      // 更新列表中的 Todo
      setState(() {
        _todos[index] = edited;
        _sortTodos();
      });
      _saveTodos();
    }
  }

  void _deleteTodo(int index) async {
    setState(() => _todos.removeAt(index));
    await _saveTodos();
  }

  void _addTodo() async {
    final newTodo = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(
        builder: (_) => TodoEditPage(onSave: (t) => Navigator.pop(context, t)),
      ),
    );
    if (newTodo != null) {
      setState(() => _todos.add(newTodo));
      _saveTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List - Sort: ${_sortType.name}'),
        actions: [
          if (_todos.isNotEmpty)
            PopupMenuButton<SortType>(
              onSelected: _changeSort,
              itemBuilder: (context) => SortType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      if (_sortType == type) const Icon(Icons.check, size: 18),
                      const SizedBox(width: 4),
                      Text(type.name),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      body: _todos.isEmpty
          ? const Center(child: Text("No TODOs yet"))
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(todo.status),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textColor(),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todo.subtitle != null &&
                              todo.subtitle!.isNotEmpty)
                            Text(
                              todo.subtitle!,
                              style: TextStyle(color: _textColor()),
                            ),
                          if (todo.description != null &&
                              todo.description!.isNotEmpty)
                            Text(
                              todo.description!,
                              style: TextStyle(color: _textColor()),
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
                                setState(() {
                                  _todos[index].status = newStatus;
                                  //_sortTodos();
                                });
                                _saveTodos();
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
                            onPressed: () => _editTodo(index),
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
                                          Navigator.pop(context, false), // 取消
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true), // 确认
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                _deleteTodo(index);
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
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
