import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class SettingPage extends StatelessWidget {
  final ValueNotifier<int> refreshNotifier; // 用来刷新列表
  final VoidCallback onToggleTheme;

  const SettingPage({
    Key? key,
    required this.refreshNotifier,
    required this.onToggleTheme,
  }) : super(key: key);

  String _randomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final rand = Random();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  List<Todo> _generateRandomTodos() {
    final rand = Random();
    return List.generate(5, (i) {
      final randomLetters = _randomString(5 + rand.nextInt(4)); // 生成5~8个随机字母
      return Todo(
        title: "Task $randomLetters",
        subtitle: "Auto generated",
        description: "This is a random task",
        status: TodoStatus.values[rand.nextInt(TodoStatus.values.length)],
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
      );
    });
  }

  void _addBatch(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList('todos') ?? [];
    final newTodos = _generateRandomTodos();
    final updated = [
      ...current,
      ...newTodos.map((e) => jsonEncode(e.toJson())),
    ];
    await prefs.setStringList('todos', updated);

    refreshNotifier.value++; // 触发列表刷新

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added 5 random todos!")));
  }

  void _cleanAll(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('todos');
    refreshNotifier.value++; // 刷新列表

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("All todos cleared!")));
  }

  void _toggleTheme(BuildContext context, VoidCallback toggle) {
    toggle();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Theme toggled!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _addBatch(context),
              child: const Text("Add 5 Random Todos"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _cleanAll(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Clean All"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _toggleTheme(context, onToggleTheme),
              child: const Text("Toggle Theme (Light/Dark)"),
            ),
          ],
        ),
      ),
    );
  }
}
