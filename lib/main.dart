import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/todo_list_page.dart';
import 'pages/todo_setting_page.dart';
import 'riverpod_main.dart';

void main() {
  runApp(const ProviderScope(child: TodoApp()));
}

class TodoApp extends ConsumerStatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  ConsumerState<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends ConsumerState<TodoApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [TodoListPage(), SettingPage()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Setting",
            ),
          ],
        ),
      ),
    );
  }
}
