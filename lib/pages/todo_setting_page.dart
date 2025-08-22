import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../todo_riverpod.dart';
import '../utils/random_list.dart';
import '../utils/ui_helpers.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                final randomTodos = TodoGenerator.generateRandomTodos(5);
                ref.read(todosProvider.notifier).addMultiple(randomTodos);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added 5 random todos!")),
                );
              },
              child: const Text("Add 5 Random Todos"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => TodoUIActions.cleanAllTodos(context, ref),

              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Clean All"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => TodoUIActions.toggleThemeMode(context, ref),
              child: const Text("Toggle Theme (Light/Dark)"),
            ),
          ],
        ),
      ),
    );
  }
}
